### Flow Engine
# Coderman64 2021.

# FIXME: 8 appears to be a "magic number", find out what it's referring to, turn it into a variable.
# FIXME: 21 is a "magic number", change to a variable once its purpose has been determined.
# FIXME: Replace variables defined in _ready with onready var.
# FIXME: What functions could be taken out and placed in a more general "helper" class or singleton?
# FIXME: Gravity, acceleration etc. are a bunch of "magic numbers" that need more explanation.

extends Area2D

# audio streams for Sonic's various sound effects
export(AudioStream) var boost_sfx
export(AudioStream) var stomp_sfx
export(AudioStream) var stomp_land_sfx

# a reference to a bouncing ring prefab, so we can spawn a bunch of them when
# sonic is hurt
export(PackedScene) var bounceRing
export(PackedScene) var boostParticle

# a list of particle systems for Sonic to control with his speed
# used for the confetti in the carnival level, or the falling leaves in leaf storm
var parts = []

var text_label	# a little text label attached to sonic for debugging

# sonic's ground state. 0 means he's on the ground, and -1 means he's in the
# air. This is not a boolean because of legacy code and stuff.
var state = -1

# can the player shorten the jump (aka was this -1 (air) state
# initiated by a jump?)
var canShort := false

# sonic's gravity
export(float) var GRAVITY = 0.3 / 4
# sonic's acceleration on his own
export(float) var ACCELERATION = 0.15 / 4
# how much sonic decelerates when skidding.
export(float) var SKID_ACCEL = 1
# sonic's acceleration in the air.
export(float) var AIR_ACCEL = 0.1 / 4
# maximum speed under sonic's own power
export(float) var MAX_SPEED = 20 / 2
# the speed of sonic's boost. Generally just a tad higher than MAX_SPEED
export(float) var BOOST_SPEED = 25 /2

# used to dampen Sonic's movement a little bit. Basically poor man's friction
export(float, 1) var SPEED_DECAY = 0.2 /2

# what velocity should sonic jump at?
export(float) var JUMP_VELOCITY = 3.5
# what is the Velocity that sonic should slow to when releasing the jump button?
export(float) var JUMP_SHORT_LIMIT = 1.5

# how fast (in pixels per 1/120th of a second) should sonic stomp
export(float) var STOMP_SPEED = 20 / 2
# what is the limit to Sonic's horizontal movement when stomping?
export(float) var MAX_STOMP_XVEL = 2 / 2

# the speed at which the camera should typically follow sonic
export(float) var DEFAULT_CAM_LAG = 20
# the speed at which the camera should follow sonic when starting a boost
export(float) var BOOST_CAM_LAG = 0
# how fast the Boost lag should slide back to the default lag while boosting
export(float, 1) var CAM_LAG_SLIDE = 0.01

# how long is Sonic's boost/stomp trail?
var TRAIL_LENGTH = 40

# state flags
var crouching := false
var spindashing := false
var rolling := false
var grinding := false
var stomping := false
var boosting := false
var tricking := false
var trickingCanStop := false

var lastPos := Vector2.ZERO

# flags and values for getting hurt
var hurt := false
var invincible = 0

# Movement strength/direction.
var movement_direction := 0.0

# grinding values.
var grindPos := Vector2.ZERO	# the origin position of the currently grinded rail
var grindOffset := 0.0		# how far along the rail (in pixels) is sonic?
var grindCurve = null		# the curve that sonic is currently grinding on
var grindVel := 0.0			# the velocity along the grind rail at which sonic is currently moving
var grindHeight = 16		# how high above the rail is the center of Sonic's sprite?

# references to all the various raycasting nodes used for Sonic's collision with
# the map
onready var LeftCast = find_node ("LeftCast")
onready var RightCast = find_node ("RightCast")
onready var LSideCast = find_node ("LSideCast")
onready var RSideCast = find_node ("RSideCast")
onready var LeftCastTop = find_node ("LeftCastTop")
onready var RightCastTop = find_node ("RightCastTop")

# a reference to Sonic's physics collider
onready var collider = find_node ("playerCollider")

# sonic's sprites/renderers
onready var sprite1 = find_node ("PlayerSprites")		# sonic's sprite
onready var boostSprite = find_node ("BoostSprite")	# the sprite that appears over sonic while boosting
onready var boostLine = find_node ("BoostLine")	# the line renderer for boosting and stomping

onready var boostBar = get_node ("/root/Node2D/CanvasLayer/boostBar")	# holds a reference to the boost UI bar
onready var ringCounter = get_node ("/root/Node2D/CanvasLayer/RingCounter")	# holds a reference to the ring counter UI item

onready var boostSound = find_node ("BoostSound")	# the audio stream player with the boost sound
onready var RailSound = find_node ("RailSound")	# the audio stream player with the rail grinding sound
onready var voiceSound = find_node ("Voice")	# the audio stream player with the character's voices

# the minimum and maximum speed/pitch changes on the grinding sound
var RAILSOUND_MINPITCH = 0.5
var RAILSOUND_MAXPITCH = 2.0

onready var cam = find_node ("Camera2D")
onready var grindParticles = find_node ("GrindParticles")	# a reference to the particle node for griding

var avgGPoint := Vector2.ZERO	#average Ground position between the two foot raycasts
var avgTPoint := Vector2.ZERO	#average top position between the two head raycasts
var avgGRot := 0.0					# average ground rotation between the two foot raycasts
var langle := 0.0					# the angle of the left foot raycast
var rangle := 0.0					# the angle of the right foot raycast
var lRot := 0.0						# Sonic's rotation during the last frame
var startpos := Vector2.ZERO		# the position at which sonic starts the level
var startLayer := 0.0				# the layer on which sonic starts

var velocity1 := Vector2.ZERO	# sonic's current velocity

var gVel := 0.0		# the ground velocity
var pgVel := 0.0	# the ground velocity during the previous frame

var backLayer := false	# whether or not sonic is currently on the "back" layer

func _ready () -> void:
	# put all child particle systems in parts except for the grind particles
	for i in get_children ():
		if i is Particles2D and not i == grindParticles:
			parts.append (i)

	# get the debug label
	text_label = find_node ("RichTextLabel")

	# set the start position and layer
	startpos = position
	startLayer = collision_layer
	setCollisionLayer (false)

	# set the trail length to whatever the boostLine's size is.
	TRAIL_LENGTH = boostLine.points.size ()

	# reset all game values
	resetGame ()
	return

func limitAngle (ang:float) -> float:
	# Returns the given angle as an angle (in radians) between -PI and PI
	var sign1 := 1.0
	if not ang == 0:
		sign1 = ang/abs (ang)
	ang = fmod (ang, PI*2)
	if abs (ang) > PI:
		ang = (2*PI-abs (ang))*sign1*-1
	return (ang)

func _input (_event: InputEvent) -> void:
	if (Input.is_action_just_pressed ("toggle_pause")):
		# TODO: Crude and hacky but pausing works. Make it less crude and hacky!
		helper_functions.add_path_to_node ("res://Scenes/UI/menu_options.tscn", "/root/Node2D/CanvasLayer")
	movement_direction = (Input.get_action_strength ("move right")-Input.get_action_strength("move left"))
	return

func angleDist (rot1:float, rot2:float) -> float:
	# returns the angle distance between rot1 and rot2, even over the 360deg mark
	# (i.e. 350 and 10 will be 20 degrees apart)
	rot1 = limitAngle (rot1)
	rot2 = limitAngle (rot2)
	if abs (rot1-rot2) > PI and rot1>rot2:
		return (abs (limitAngle (rot1)-(limitAngle (rot2)+PI*2)))
	elif abs (rot1-rot2) > PI and rot1<rot2:
		return (abs ((limitAngle (rot1)+PI*2)-(limitAngle (rot2))))
	else:
		return abs (rot1-rot2)

func boostControl () -> void:
	# handles the boosting controls

	if Input.is_action_just_pressed ("boost") and boostBar.boostAmount > 0:
		# setup the boost when the player first presses the boost button

		# set boosting to true
		boosting = true

		# reset the boost line points
		for i in range (0, TRAIL_LENGTH):
			boostLine.points[i] = Vector2.ZERO

		# play the boost sfx
		boostSound.stream = boost_sfx
		boostSound.play ()

		# set the camera smoothing to the initial boost lag
		cam.set_follow_smoothing (BOOST_CAM_LAG)

		# stop moving vertically as much if you are in the air (air boost)
		if state == -1 and velocity1.x < ACCELERATION:
			velocity1.x = BOOST_SPEED*(1 if sprite1.flip_h else -1)
			velocity1.y = 0

		voiceSound.play_effort ()

	if Input.is_action_pressed ("boost") and boosting and boostBar.boostAmount > 0:
#		if boostSound.stream != boost_sfx:
#			boostSound.stream = boost_sfx
#			boostSound.play ()

		# linearly interpolate the camera's "boost lag" back down to the normal (non-boost) value
		cam.set_follow_smoothing (lerp (cam.get_follow_smoothing (), DEFAULT_CAM_LAG, CAM_LAG_SLIDE))

		if grinding:
			# apply boost to a grind
			grindVel = BOOST_SPEED*(1 if sprite1.flip_h else -1)
		elif state == 0:
			# apply boost if you are on the ground
			gVel = BOOST_SPEED*(1 if sprite1.flip_h else -1)
		elif angleDist (velocity1.angle (), 0) < PI/3 or angleDist (velocity1.angle (), PI) < PI/3:
			# apply boost if you are in the air (and are not going straight up or down
			velocity1 = velocity1.normalized ()*BOOST_SPEED
		else:
			# if none of these situations fit, you shouldn't be boosting here!
			boosting = false

		# set the visibility and rotation of the boost line and sprite
		boostSprite.visible = true
		boostSprite.rotation = velocity1.angle () - rotation
		boostLine.visible = true
		boostLine.rotation = -rotation

		# decrease boost value while boosting
		boostBar.changeBy (-0.06)
	else:
		# the camera lag should be normal while not boosting
		cam.set_follow_smoothing (DEFAULT_CAM_LAG)

		# stop the boost sound, if it is playing
		if boostSound.stream == boost_sfx:
			boostSound.stop ()

		# disable all visual boost indicators
		boostSprite.visible = false
		boostLine.visible = false

		# we're not boosting, so set boosting to false
		boosting = false
	return

func airProcess () -> void:
	# handles physics while Sonic is in the air

	# apply gravity
	velocity1 = Vector2 (velocity1.x, velocity1.y+GRAVITY)

	# get the angle of the point for the left and right floor raycasts
	langle = limitAngle (-atan2 (LeftCast.get_collision_normal ().x, LeftCast.get_collision_normal ().y)-PI)
	rangle = limitAngle (-atan2 (RightCast.get_collision_normal ().x, RightCast.get_collision_normal ().y)-PI)

	# calculate the average ground rotation (averaged between the points)
	avgGRot = (langle+rangle)/2

	# set a default avgGPoint
	avgGPoint = Vector2.INF

	# calculate the average ground point (the elifs are for cases where one
	# raycast cannot find a collider)
	if (LeftCast.is_colliding () and RightCast.is_colliding ()):
		text_label.text += "Left & Right Collision"
		var LeftCastPt = Vector2 (
			LeftCast.get_collision_point ().x+cos (rotation)*8,
			LeftCast.get_collision_point ().y+sin (rotation)*8)
		var RightCastPt = Vector2 (
			RightCast.get_collision_point ().x-cos (rotation)*8,
			RightCast.get_collision_point ().y-sin (rotation)*8)
		avgGPoint = (LeftCastPt if position.distance_to (LeftCastPt) < position.distance_to (RightCastPt) else RightCastPt)
	elif LeftCast.is_colliding ():
		text_label.text += "Left Collision"
		avgGPoint = Vector2 (LeftCast.get_collision_point ().x+cos (rotation)*8, LeftCast.get_collision_point ().y+sin (rotation)*8)
		avgGRot = langle
	elif RightCast.is_colliding ():
		text_label.text += "Right Collision"
		avgGPoint = Vector2 (RightCast.get_collision_point ().x-cos (rotation)*8, RightCast.get_collision_point ().y-sin (rotation)*8)
		avgGRot = rangle

	# calculate the average ceiling height based on the collision raycasts
	# (again, elifs are for cases where only one raycast is successful)
	if (LeftCastTop.is_colliding () and RightCastTop.is_colliding ()):
		avgTPoint = Vector2 (
			(LeftCastTop.get_collision_point ().x+RightCastTop.get_collision_point ().x)/2,
			(LeftCastTop.get_collision_point ().y+RightCastTop.get_collision_point ().y)/2)
	elif LeftCastTop.is_colliding ():
		avgTPoint = Vector2 (LeftCastTop.get_collision_point ().x+cos (rotation)*8, LeftCastTop.get_collision_point ().y+sin (rotation)*8)
	elif RightCastTop.is_colliding ():
		avgTPoint = Vector2 (RightCastTop.get_collision_point ().x-cos (rotation)*8, RightCastTop.get_collision_point ().y-sin (rotation)*8)

	# handle collision with the ground
	if abs (avgGPoint.y-position.y) < 21: #-velocity1.y
	#if avgGPoint.distance_to (position) < 21:
#		print ("ground hit")
		state = 0
		rotation = avgGRot
		sprite1.rotation = 0
		gVel = sin (rotation)*(velocity1.y+0.5)+cos (rotation)*velocity1.x

		# play the stomp sound if you were stomping
		if stomping:
			boostSound.stream = stomp_land_sfx
			boostSound.play ()
			stomping = false
	else:
#		print ("GROUND MISS: %s" % str (avgGPoint))
		return

	# air-based movement (using the arrow keys)
	#if Input.is_action_pressed ("move right") and velocity1.x < 16:
	#	velocity1 = Vector2 (velocity1.x+AIR_ACCEL, velocity1.y)
	#elif Input.is_action_pressed ("move left") and velocity1.x > -16:
#		velocity1 = Vector2 (velocity1.x-AIR_ACCEL, velocity1.y)
	velocity1 = Vector2 (velocity1.x-AIR_ACCEL * movement_direction, velocity1.y)

	### STOMPING CONTROLS ###

	# initiating a stomp
	if Input.is_action_just_pressed ("stomp") and not stomping:

		# set the stomping state, and animation state
		stomping = true
		sprite1.animation = "Roll"
		rotation = 0
		sprite1.rotation = 0

		# clear all points in the boostLine rendered line
		for i in range (0, TRAIL_LENGTH):
			boostLine.points[i] = Vector2.ZERO

		# play sound
		boostSound.stream = stomp_sfx
		boostSound.play ()

	# for every frame while a stomp is occuring...
	if stomping:
		velocity1 = Vector2 (max (-MAX_STOMP_XVEL, min (MAX_STOMP_XVEL, velocity1.x)), STOMP_SPEED)

		# make sure that the boost sprite is not visible
		boostSprite.visible = false;

		# manage the boost line
		boostLine.visible = true
		boostLine.rotation = -rotation

		# don't run the boost code when stomping
	else:
		boostControl ()

	# slowly slide Sonic's rotation back to zero as you fly through the air
	sprite1.rotation = lerp (sprite1.rotation, 0, 0.1)

	# handle left and right sideways collision (respectively)
	if LSideCast.is_colliding () and LSideCast.get_collision_point ().distance_to (position+velocity1) < 14 and velocity1.x < 0:
		velocity1 = Vector2 (0, velocity1.y)
		position = LSideCast.get_collision_point () + Vector2 (14, 0)
		boosting = false
	if RSideCast.is_colliding () and RSideCast.get_collision_point ().distance_to (position+velocity1) < 14 and velocity1.x > 0:
		velocity1 = Vector2 (0, velocity1.y)
		position = RSideCast.get_collision_point () - Vector2 (14, 0)
		boosting = false

	# top collision
	if avgTPoint.distance_to (position+velocity1) < 21:
#		Vector2 (avgTPoint.x-20*sin (rotation), avgTPoint.y+20*cos (rotation))
		velocity1 = Vector2 (velocity1.x, 0)

	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if not Input.is_action_pressed ("jump") and canShort:
		velocity1 = Vector2 (velocity1.x, max (velocity1.y, -JUMP_SHORT_LIMIT))

	# ensure the proper speed of the animated sprites
	sprite1.speed_scale = 1
	return

func gndProcess () -> void:
	# caluclate the ground rotation for the left and right raycast colliders,
	# respectively
	langle = -atan2 (LeftCast.get_collision_normal ().x, LeftCast.get_collision_normal ().y)-PI
	langle = limitAngle (langle)
	rangle = -atan2 (RightCast.get_collision_normal ().x, RightCast.get_collision_normal ().y)-PI
	rangle = limitAngle (rangle)

	# calculate the average ground rotation
	if abs (langle-rangle) < PI:
		avgGRot = limitAngle ((langle+rangle)/2)
	else:
		avgGRot = limitAngle ((langle+rangle+PI*2)/2)

	# caluculate the average ground level based on the available colliders
	if (LeftCast.is_colliding () and RightCast.is_colliding ()):
		avgGPoint = Vector2 ((LeftCast.get_collision_point ().x+RightCast.get_collision_point ().x)/2, (LeftCast.get_collision_point ().y+RightCast.get_collision_point ().y)/2)
		# ((acos (LeftCast.get_collision_normal ().y/1)+PI)+(acos (RightCast.get_collision_normal ().y/1)+PI))/2
	elif LeftCast.is_colliding ():
		avgGPoint = Vector2 (LeftCast.get_collision_point ().x+cos (rotation)*8, LeftCast.get_collision_point ().y+sin (rotation)*8)
		avgGRot = langle
	elif RightCast.is_colliding ():
		avgGPoint = Vector2 (RightCast.get_collision_point ().x-cos (rotation)*8, RightCast.get_collision_point ().y-sin (rotation)*8)
		avgGRot = rangle

	# set the rotation and position of Sonic to snap to the ground.
	rotation = avgGRot
	position = Vector2 (avgGPoint.x+20*sin (rotation), avgGPoint.y-20*cos (rotation))

	if not rolling:
		# handle rightward acceleration
		if Input.is_action_pressed ("move right") and gVel < MAX_SPEED:
			gVel = gVel + ACCELERATION
			# "skid" mechanic, to more quickly accelerate when reversing
			# (this makes Sonic feel more responsive)
			if gVel < 0:
				gVel = gVel + SKID_ACCEL

		# handle leftward acceleration
		elif Input.is_action_pressed ("move left") and gVel > -MAX_SPEED:
			gVel = gVel - ACCELERATION

			# "skid" mechanic (see rightward section)
			if gVel > 0:
				gVel = gVel - SKID_ACCEL
		else:
			# general deceleration and stopping if no key is pressed
			# declines at a constant rate
			if not gVel == 0:
				gVel -= SPEED_DECAY*(gVel/abs (gVel))
			if abs (gVel) < SPEED_DECAY*1.5:
				gVel = 0
	else:
		# general deceleration and stopping if no key is pressed
		# declines at a constant rate
		if not gVel == 0:
			gVel -= SPEED_DECAY*(gVel/abs (gVel))*0.3
		if abs (gVel) < SPEED_DECAY*1.5:
			gVel = 0

	# left and right wall collision, respectively
	if LSideCast.is_colliding () and LSideCast.get_collision_point ().distance_to (position) < 21 and gVel < 0:
		gVel = 0
		position = LSideCast.get_collision_point () + Vector2 (position.x-LSideCast.get_collision_point ().x, position.y-LSideCast.get_collision_point ().y).normalized ()*21
		boosting = false
	if RSideCast.is_colliding () and RSideCast.get_collision_point ().distance_to (position) < 21 and gVel > 0:
		gVel = 0
		position = RSideCast.get_collision_point () + Vector2 (position.x-RSideCast.get_collision_point ().x, position.y-RSideCast.get_collision_point ().y).normalized ()*21
		boosting = false

	# apply gravity if you are on a slope, and apply the ground velocity
	gVel += sin (rotation)*GRAVITY
	velocity1 = Vector2 (cos (rotation)*gVel, sin (rotation)*gVel)

	# enter the air state if you run off a ramp, or walk off a cliff, or something
	if not avgGPoint.distance_to (position) < 21 or not (LeftCast.is_colliding () and RightCast.is_colliding ()):
		state = -1
		sprite1.rotation = rotation
		rotation = 0
		rolling = false

	# fall off of walls if you aren't going fast enough
	if abs (rotation) >= PI/3 and (abs (gVel) < 0.2 or (not gVel == 0 and not pgVel == 0 and not gVel/abs (gVel) == pgVel/abs (pgVel))):
		state = -1
		sprite1.rotation = rotation
		rotation = 0
		position = Vector2 (position.x-sin (rotation)*2, position.y+cos (rotation)*2)
		rolling = false

	# set Sonic's sprite based on his ground velocity
	# FIXME: Replace "magic numbers" here with variables, e.g. 0.02 with "walk_threshold"?
	if not rolling:
		if abs (gVel) > 12/2:
			sprite1.animation = "Run4"
		elif abs (gVel) > 10/2:
			sprite1.animation = "Run3"
		elif abs (gVel) > 5/2:
			sprite1.animation = "Run2"
		elif abs (gVel) > 0.02:
			sprite1.animation = "Walk"
		elif not crouching:
			sprite1.animation = "idle"
	else:
		sprite1.animation = "Roll"

	if abs (gVel) > 0.02:
		crouching = false
		sprite1.speed_scale = 1
	else:
		gVel = 0
		rolling = false

	if Input.is_action_pressed ("ui_down") and abs (gVel) <= 0.02:
		crouching = true
		sprite1.animation = "Crouch"
		sprite1.speed_scale = 1
		if sprite1.frame > 3:
			sprite1.speed_scale = 0
	elif crouching == true:
		sprite1.animation = "Crouch"
		sprite1.speed_scale = 1
		if sprite1.frame >= 6:
			sprite1.speed_scale = 1
			crouching = false

	# run boost controls
	boostControl ()

	# jumping
	if Input.is_action_pressed ("jump") and not crouching:
		if not canShort:
			state = -1
			velocity1 = Vector2 (velocity1.x+sin (rotation)*JUMP_VELOCITY, velocity1.y-cos (rotation)*JUMP_VELOCITY)
			sprite1.rotation = rotation
			rotation = 0
			sprite1.animation = "Roll"
			canShort = true
			rolling = false
	else:
		canShort = false

	if (Input.is_action_pressed ("jump") and crouching) or spindashing:
		spindashing = true
		sprite1.animation = "Spindash"
		sprite1.speed_scale = 1
		if not Input.is_action_pressed ("ui_down"):
			gVel = 15 *(1 if sprite1.flip_h else -1)
			spindashing = false
			rolling = true

	# set the previous ground velocity and last rotation for next frame
	pgVel = gVel
	lRot = rotation
	return

func _physics_process (_delta) -> void:
	# calculate Sonic's physics, controls, and all that fun stuff
	if invincible > 0:	# Invincible? If so, run the counter down.
		invincible -= 1
		sprite1.modulate = Color (1, 1, 1, 1-(invincible % 30)/30.0)
	else:
		hurt = false
	# reset using the dedicated reset button
	if Input.is_action_pressed ('restart'):
		resetGame ()
		if get_tree ().reload_current_scene () != OK:
			printerr ("ERROR: Could not reload current scene!")
			get_tree ().quit ()

	grindParticles.emitting = grinding

	# run the correct function based on the current air/ground state
	if grinding:
		if tricking:
			sprite1.animation = "railTrick"
			sprite1.speed_scale = 1
			if sprite1.frame > 0:
				trickingCanStop = true
			if sprite1.frame <= 0 and trickingCanStop:
				tricking = false
				var part = boostParticle.instance ()
				part.position = position
				part.boostValue = 2
				get_node ("/root/Node2D").add_child (part)
		else:
			sprite1.animation = "Grind"

		if Input.is_action_just_pressed ("stomp") and not tricking:
			tricking = true
			trickingCanStop = false
			voiceSound.play_effort ()

		grindHeight = sprite1.frames.get_frame (sprite1.animation, sprite1.frame).get_height ()/2

		grindOffset += grindVel
		var dirVec = grindCurve.interpolate_baked (grindOffset+1)-grindCurve.interpolate_baked (grindOffset)
#		grindVel = velocity1.dot (dirVec)
		rotation = dirVec.angle ()
		position = grindCurve.interpolate_baked (grindOffset)\
			+Vector2.UP*grindHeight*cos (rotation)+Vector2.RIGHT*grindHeight*sin (rotation)\
			+grindPos

		RailSound.pitch_scale = lerp (RAILSOUND_MINPITCH, RAILSOUND_MAXPITCH, \
			abs (grindVel)/BOOST_SPEED)
		grindVel += sin (rotation)*GRAVITY

		if dirVec.length () < 0.5 or \
			grindCurve.interpolate_baked (grindOffset-1) == \
			grindCurve.interpolate_baked (grindOffset):
			state = -1
			grinding = false
			tricking = false
			trickingCanStop = false
			RailSound.stop ()
		else:
			velocity1 = dirVec*grindVel

		if Input.is_action_pressed ("jump") and not crouching:
			if not canShort:
				state = -1
				velocity1 = Vector2 (velocity1.x+sin (rotation)*JUMP_VELOCITY, velocity1.y-cos (rotation)*JUMP_VELOCITY)
				sprite1.rotation = rotation
				rotation = 0
				sprite1.animation = "Roll"
				canShort = true
				rolling = false
				grinding = false
				tricking = false
				trickingCanStop = false
				RailSound.stop ()
		else:
			canShort = false
		boostControl ()
	elif state == -1:
		airProcess ()
		rolling = false
	elif state == 0:
		gndProcess ()

	# update the boost line
	for i in range (0, TRAIL_LENGTH-1):
		boostLine.points[i] = (boostLine.points[i+1]-velocity1+ (lastPos-position))
	boostLine.points[TRAIL_LENGTH-1] = Vector2.ZERO
	if (stomping):
		boostLine.points[TRAIL_LENGTH-1] = Vector2 (0, 8)

	# apply the character's velocity, no matter what state the player is in.
	position = Vector2 (position.x+velocity1.x, position.y+velocity1.y)
	lastPos = position

	if (parts):
		for i in parts:
			i.process_material.direction = Vector3 (velocity1.x, velocity1.y, 0)
			i.process_material.initial_velocity = velocity1.length ()*20
			i.rotation = -rotation

	# ensure Sonic is facing the right direction
	sprite1.flip_h = (false if velocity1.x < 0.0 else (true if velocity1.x > 0.0 else sprite1.flip_h))

	return

func setCollisionLayer (value) -> void:
	# shortcut to change the collision mask for every raycast node connected to
	# sonic at the same time. Value is true for layer 1, false for layer 0
	backLayer = value
	LeftCast.set_collision_mask_bit (0, not backLayer)
	LeftCast.set_collision_mask_bit (1, backLayer)
	RightCast.set_collision_mask_bit (0, not backLayer)
	RightCast.set_collision_mask_bit (1, backLayer)
	RSideCast.set_collision_mask_bit (0, not backLayer)
	RSideCast.set_collision_mask_bit (1, backLayer)
	LSideCast.set_collision_mask_bit (0, not backLayer)
	LSideCast.set_collision_mask_bit (1, backLayer)
	LeftCastTop.set_collision_mask_bit (0, not backLayer)
	LeftCastTop.set_collision_mask_bit (1, backLayer)
	RightCastTop.set_collision_mask_bit (0, not backLayer)
	RightCastTop.set_collision_mask_bit (1, backLayer)
	return

func _flipLayer (_body) -> void:
	# toggle between layers
	setCollisionLayer (not backLayer)
	return # replace with function body

func _layer0 (area) -> void:
	# explicitly set the collision layer to 0
	print ("layer0", area.name)
	setCollisionLayer (false)
	return # replace with function body

func _layer1 (area) -> void:
	# explicitly set the collision layer to 1
	print ("layer1", area.name)
	setCollisionLayer (true)
	return # replace with function body

func _on_DeathPlane_area_entered (area) -> void:
	if self == area:
		resetGame ()
		if get_tree ().reload_current_scene () != OK:
			printerr ("ERROR: Could not reload current scene!")
			get_tree ().quit ()
	return

func resetGame () -> void:
	# reset your position and state if you pull a dimps (fall out of the world)
	velocity1 = Vector2.ZERO
	state = -1
	position = startpos
	setCollisionLayer (false)
	return

func _setVelocity (vel) -> void:
	velocity1 = vel
	return

func _on_Railgrind (area, curve, origin) -> void:
	# this function is run whenever sonic hits a rail.

	# stick to the current rail if you're already grinding
	if grinding:
		return

	# activate grind, if you are going downward
	if self == area and velocity1.y > 0:
		grinding = true
		grindCurve = curve
		grindPos = origin
		grindOffset = grindCurve.get_closest_offset (position-grindPos)
		grindVel = velocity1.x

		RailSound.play ()

		# play the sound if you were stomping
		if stomping:
			boostSound.stream = stomp_land_sfx
			boostSound.play ()
			stomping = false
	return

func isAttacking () -> bool:
	return (stomping or boosting or rolling or (sprite1.animation == "Roll" and state == -1))

func hurt_player () -> void:
	if not invincible > 0:
		invincible = 120*5
		state = -1
		velocity1 = Vector2 (-velocity1.x+sin (rotation)*JUMP_VELOCITY, velocity1.y-cos (rotation)*JUMP_VELOCITY)
		rotation = 0
		position += velocity1*2
		sprite1.animation = "hurt"

		voiceSound.play_hurt ()

		var t = 0
		var angle := 101.25
		var n := false
		var speed = 4

		while t < min (ringCounter.ringCount, 32):
			var currentRing = bounceRing.instance ()
			currentRing.velocity1 = Vector2 (-sin (angle)*speed, cos (angle)*speed)/2
			currentRing.position = position
			if n:
				currentRing.velocity1.x *= -1
				angle += 22.5
			n = not n
			t += 1
			if t == 16:
				speed = 2
				angle = 101.25
			get_node ("/root/Node2D").call_deferred ("add_child", currentRing)
		ringCounter.ringCount = 0
	return

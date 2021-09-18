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

# Player's last position.
var last_position := Vector2.ZERO

# Speed thresholds for the player.
export(float) var walk_threshold = 0.02
export(float) var jog_threshold = 5/2
export(float) var run_threshold = 10/2
export(float) var fast_threshold = 12/2

# flags and values for getting hurt
var hurt := false
var invincible := 0

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
var start_position := Vector2.ZERO		# the position at which sonic starts the level
var startLayer := 0.0				# the layer on which sonic starts

var player_velocity := Vector2.ZERO	# sonic's current velocity

var ground_velocity := 0.0		# the ground velocity
var previous_ground_velocity := 0.0	# the ground velocity during the previous frame

var backLayer := false	# whether or not sonic is currently on the "back" layer

func _ready () -> void:
	# put all child particle systems in parts except for the grind particles
	for i in get_children ():
		if i is Particles2D and not i == grindParticles:
			parts.append (i)

	# get the debug label
	text_label = find_node ("RichTextLabel")

	# set the start position and layer
	start_position = position
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
	movement_direction = (Input.get_action_strength ("move_right") - Input.get_action_strength ("move_left"))
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
		if state == -1 and player_velocity.x < ACCELERATION:
			player_velocity.x = BOOST_SPEED*(1 if sprite1.flip_h else -1)
			player_velocity.y = 0

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
			ground_velocity = BOOST_SPEED*(1 if sprite1.flip_h else -1)
		elif angleDist (player_velocity.angle (), 0) < PI/3 or angleDist (player_velocity.angle (), PI) < PI/3:
			# apply boost if you are in the air (and are not going straight up or down
			player_velocity = player_velocity.normalized ()*BOOST_SPEED
		else:
			# if none of these situations fit, you shouldn't be boosting here!
			boosting = false

		# set the visibility and rotation of the boost line and sprite
		boostSprite.visible = true
		boostSprite.rotation = player_velocity.angle () - rotation
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
	player_velocity = Vector2 (player_velocity.x, player_velocity.y+GRAVITY)

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
	if abs (avgGPoint.y-position.y) < 21: #-player_velocity.y
		print_debug ("Ground hit at ", position)
		state = 0
		rotation = avgGRot
		sprite1.rotation = 0
		ground_velocity = sin (rotation)*(player_velocity.y+0.5)+cos (rotation)*player_velocity.x

		# play the stomp sound if you were stomping
		if stomping:
			boostSound.stream = stomp_land_sfx
			boostSound.play ()
			stomping = false

	# air-based movement
	if (abs (player_velocity.x) < 16):
		player_velocity = Vector2 (player_velocity.x+(AIR_ACCEL * movement_direction), player_velocity.y)

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
		player_velocity = Vector2 (max (-MAX_STOMP_XVEL, min (MAX_STOMP_XVEL, player_velocity.x)), STOMP_SPEED)

		# make sure that the boost sprite is not visible
		boostSprite.visible = false

		# manage the boost line
		boostLine.visible = true
		boostLine.rotation = -rotation

		# don't run the boost code when stomping
	else:
		boostControl ()

	# slowly slide Sonic's rotation back to zero as you fly through the air
	sprite1.rotation = lerp (sprite1.rotation, 0, 0.1)

	# handle left and right sideways collision (respectively)
	if LSideCast.is_colliding () and LSideCast.get_collision_point ().distance_to (position+player_velocity) < 14 and player_velocity.x < 0:
		player_velocity = Vector2 (0, player_velocity.y)
		position = LSideCast.get_collision_point () + Vector2 (14, 0)
		boosting = false
	if RSideCast.is_colliding () and RSideCast.get_collision_point ().distance_to (position+player_velocity) < 14 and player_velocity.x > 0:
		player_velocity = Vector2 (0, player_velocity.y)
		position = RSideCast.get_collision_point () - Vector2 (14, 0)
		boosting = false

	# top collision
	if avgTPoint.distance_to (position+player_velocity) < 21:
#		Vector2 (avgTPoint.x-20*sin (rotation), avgTPoint.y+20*cos (rotation))
		player_velocity = Vector2 (player_velocity.x, 0)

	# Allow the player to change the duration of the jump by releasing the jump
	# button early
	if not Input.is_action_pressed ("jump") and canShort:
		player_velocity = Vector2 (player_velocity.x, max (player_velocity.y, -JUMP_SHORT_LIMIT))

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
		if movement_direction > 0 and ground_velocity < MAX_SPEED:
			ground_velocity = ground_velocity + ACCELERATION
			# "skid" mechanic, to more quickly accelerate when reversing
			# (this makes Sonic feel more responsive)
			if ground_velocity < 0:
				ground_velocity = ground_velocity + SKID_ACCEL

		# handle leftward acceleration
		elif movement_direction < 0 and ground_velocity > -MAX_SPEED:
			ground_velocity = ground_velocity - ACCELERATION

			# "skid" mechanic (see rightward section)
			if ground_velocity > 0:
				ground_velocity = ground_velocity - SKID_ACCEL
		else:
			# general deceleration and stopping if no key is pressed
			# declines at a constant rate
			if not ground_velocity == 0:
				ground_velocity -= SPEED_DECAY*(ground_velocity/abs (ground_velocity))
			if abs (ground_velocity) < SPEED_DECAY*1.5:
				ground_velocity = 0
	else:
		# general deceleration and stopping if no key is pressed
		# declines at a constant rate
		if not ground_velocity == 0:
			ground_velocity -= SPEED_DECAY*(ground_velocity/abs (ground_velocity))*0.3
		if abs (ground_velocity) < SPEED_DECAY*1.5:
			ground_velocity = 0

	# left and right wall collision, respectively
	if LSideCast.is_colliding () and LSideCast.get_collision_point ().distance_to (position) < 21 and ground_velocity < 0:
		ground_velocity = 0
		position = LSideCast.get_collision_point () + Vector2 (position.x-LSideCast.get_collision_point ().x, position.y-LSideCast.get_collision_point ().y).normalized ()*21
		boosting = false
	if RSideCast.is_colliding () and RSideCast.get_collision_point ().distance_to (position) < 21 and ground_velocity > 0:
		ground_velocity = 0
		position = RSideCast.get_collision_point () + Vector2 (position.x-RSideCast.get_collision_point ().x, position.y-RSideCast.get_collision_point ().y).normalized ()*21
		boosting = false

	# apply gravity if you are on a slope, and apply the ground velocity
	ground_velocity += sin (rotation)*GRAVITY
	player_velocity = Vector2 (cos (rotation)*ground_velocity, sin (rotation)*ground_velocity)

	# enter the air state if you run off a ramp, or walk off a cliff, or something
	if not avgGPoint.distance_to (position) < 21 or not (LeftCast.is_colliding () and RightCast.is_colliding ()):
		state = -1
		sprite1.rotation = rotation
		rotation = 0
		rolling = false

	# fall off of walls if you aren't going fast enough
	if abs (rotation) >= PI/3 and (abs (ground_velocity) < 0.2 or (not ground_velocity == 0 and not previous_ground_velocity == 0 and not ground_velocity/abs (ground_velocity) == previous_ground_velocity/abs (previous_ground_velocity))):
		state = -1
		sprite1.rotation = rotation
		rotation = 0
		position = Vector2 (position.x-sin (rotation)*2, position.y+cos (rotation)*2)
		rolling = false

	# set Sonic's sprite based on his ground velocity
	if not rolling:
		if abs (ground_velocity) > fast_threshold:
			sprite1.animation = "Run4"
		elif abs (ground_velocity) > run_threshold:
			sprite1.animation = "Run3"
		elif abs (ground_velocity) > jog_threshold:
			sprite1.animation = "Run2"
		elif abs (ground_velocity) > walk_threshold:
			sprite1.animation = "Walk"
		elif not crouching:
			sprite1.animation = "idle"
	else:
		sprite1.animation = "Roll"

	if abs (ground_velocity) > walk_threshold:
		crouching = false
		sprite1.speed_scale = 1
	else:
		ground_velocity = 0
		rolling = false

	if Input.is_action_pressed ("ui_down") and abs (ground_velocity) <= walk_threshold:
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
			player_velocity = Vector2 (player_velocity.x+sin (rotation)*JUMP_VELOCITY, player_velocity.y-cos (rotation)*JUMP_VELOCITY)
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
			ground_velocity = 15*(1 if sprite1.flip_h else -1)
			spindashing = false
			rolling = true

	# set the previous ground velocity and last rotation for next frame
	previous_ground_velocity = ground_velocity
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
#		grindVel = player_velocity.dot (dirVec)
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
			player_velocity = dirVec*grindVel

		if Input.is_action_pressed ("jump") and not crouching:
			if not canShort:
				state = -1
				player_velocity = Vector2 (player_velocity.x+sin (rotation)*JUMP_VELOCITY, player_velocity.y-cos (rotation)*JUMP_VELOCITY)
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
		boostLine.points[i] = (boostLine.points[i+1]-player_velocity+ (last_position-position))
	boostLine.points[TRAIL_LENGTH-1] = Vector2.ZERO
	if (stomping):
		boostLine.points[TRAIL_LENGTH-1] = Vector2 (0, 8)

	# apply the character's velocity, no matter what state the player is in.
	position = Vector2 (position.x+player_velocity.x, position.y+player_velocity.y)
	last_position = position

	if (parts):
		for i in parts:
			i.process_material.direction = Vector3 (player_velocity.x, player_velocity.y, 0)
			i.process_material.initial_velocity = player_velocity.length ()*20
			i.rotation = -rotation

	# ensure Sonic is facing the right direction
	sprite1.flip_h = (false if movement_direction < 0 && player_velocity.x < 0.0 else (true if movement_direction > 0 && player_velocity.x > 0.0 else sprite1.flip_h))

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
	print_debug ("layer0: ", area.name)
	setCollisionLayer (false)
	return # replace with function body

func _layer1 (area) -> void:
	# explicitly set the collision layer to 1
	print_debug ("layer1: ", area.name)
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
	player_velocity = Vector2.ZERO
	state = -1
	position = start_position
	setCollisionLayer (false)
	return

func _setVelocity (vel) -> void:
	player_velocity = vel
	return

func _on_Railgrind (area, curve, origin) -> void:
	# this function is run whenever sonic hits a rail.

	# stick to the current rail if you're already grinding
	if (grinding):
		return

	# activate grind, if you are going downward
	if (self == area and player_velocity.y > 0):
		grinding = true
		grindCurve = curve
		grindPos = origin
		grindOffset = grindCurve.get_closest_offset (position-grindPos)
		grindVel = player_velocity.x

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
		player_velocity = Vector2 (-player_velocity.x+sin (rotation)*JUMP_VELOCITY, player_velocity.y-cos (rotation)*JUMP_VELOCITY)
		rotation = 0
		position += player_velocity*2
		sprite1.animation = "hurt"

		voiceSound.play_hurt ()

		var t = 0
		var angle := 101.25
		var n := false
		var speed = 4

		while t < min (ringCounter.ringCount, 32):
			var currentRing = bounceRing.instance ()
			currentRing.ring_velocity = Vector2 (-sin (angle)*speed, cos (angle)*speed)/2
			currentRing.position = position
			if n:
				currentRing.ring_velocity.x *= -1
				angle += 22.5
			n = not n
			t += 1
			if t == 16:
				speed = 2
				angle = 101.25
			get_node ("/root/Node2D").call_deferred ("add_child", currentRing)
		ringCounter.ringCount = 0
	return

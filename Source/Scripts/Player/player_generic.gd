### player_generic.gd
# Contains the variables and functions all player characters will use.

extends Area2D

# audio streams for the player's various sound effects
export(AudioStream) var boost_sfx
export(AudioStream) var stomp_sfx
export(AudioStream) var stomp_land_sfx

# a reference to a bouncing ring prefab, so we can spawn a bunch of them when
# the player is hurt
export(PackedScene) var bounceRing
export(PackedScene) var boostParticle

# a list of particle systems for the player to control with his speed
# used for the confetti in the carnival level, or the falling leaves in leaf storm
var parts = []

var text_label	# a little text label attached to the player for debugging

# the player's ground state. 0 means he's on the ground, and -1 means he's in the
# air. This is not a boolean because of legacy code and stuff.
var state = -1

# the player's gravity
export(float) var GRAVITY = 0.3 / 4
# the player's acceleration on his own
export(float) var ACCELERATION = 0.15 / 4
# how much the player decelerates when skidding.
export(float) var SKID_ACCEL = 1
# the player's acceleration in the air.
export(float) var AIR_ACCEL = 0.1 / 4
# maximum speed under the player's own power
export(float) var MAX_SPEED = 20 / 2
# the speed of the player's boost. Generally just a tad higher than MAX_SPEED
export(float) var BOOST_SPEED = 25 /2

# used to dampen the player's movement a little bit. Basically poor man's friction
export(float, 1) var SPEED_DECAY = 0.2 /2

# what velocity should the player jump at?
export(float) var JUMP_VELOCITY = 3.5
# what is the Velocity that the player should slow to when releasing the jump button?
export(float) var JUMP_SHORT_LIMIT = 1.5

# how fast (in pixels per 1/120th of a second) should the player stomp
export(float) var STOMP_SPEED = 20 / 2
# what is the limit to the player's horizontal movement when stomping?
export(float) var MAX_STOMP_XVEL = 2 / 2

# the speed at which the camera should typically follow the player
export(float) var DEFAULT_CAM_LAG = 20
# the speed at which the camera should follow the player when starting a boost
export(float) var BOOST_CAM_LAG = 0
# how fast the Boost lag should slide back to the default lag while boosting
export(float, 1) var CAM_LAG_SLIDE = 0.01

# how long is the player's boost/stomp trail?
var TRAIL_LENGTH = 40

# Capability flags. What can this character do?
export(bool) var can_boost := false		# Sonic, Blaze, Shadow etc. can boost their speed.
export(bool) var can_fly := false		# Tails, Cream etc. can fly.
export(bool) var can_glide := false		# Knuckles etc. can glide.

# state flags
var can_jump_short := false				# can the player shorten the jump?
var is_boosting := 0
var is_crouching := false
var is_flying := false
var is_gliding := false
var is_grinding := false
var is_jumping := false
var is_rolling := false
var is_spindashing := false
var is_stomping := false
var is_tricking := false
var stop_while_tricking := false		# Is/can the player stop while tricking.

# Player's last position.
var last_position := Vector2.ZERO

# Speed thresholds for the player.
export(float) var threshold_walk = 0.02
export(float) var threshold_jog = 5/2
export(float) var threshold_run_slow = 10/2
export(float) var threshold_run_fast = 12/2

# flags and values for getting hurt
var hurt := false
var invincible := 0

# Movement strength/direction.
var movement_direction := 0.0

# grinding values.
var grindPos := Vector2.ZERO	# the origin position of the currently grinded rail
var grindOffset := 0.0		# how far along the rail (in pixels) is the player?
var grindCurve = null		# the curve that the player is currently grinding on
var grindVel := 0.0			# the velocity along the grind rail at which the player is currently moving
var grindHeight = 16		# how high above the rail is the center of the player's sprite?

# references to all the various raycasting nodes used for the player's collision with
# the map
onready var LeftCast = find_node ("LeftCast")
onready var RightCast = find_node ("RightCast")
onready var LSideCast = find_node ("LSideCast")
onready var RSideCast = find_node ("RSideCast")
onready var LeftCastTop = find_node ("LeftCastTop")
onready var RightCastTop = find_node ("RightCastTop")

# a reference to the player's physics collider
onready var collider = find_node ("playerCollider")

# the player's sprites/renderers
onready var player_sprite = find_node ("PlayerSprites")		# the player's sprite
onready var boostSprite = find_node ("BoostSprite")			# the sprite that appears over the player while boosting
onready var boostLine = find_node ("BoostLine")				# the line renderer for boosting and stomping

onready var boostBar = get_node ("/root/Level/CanvasLayer/boostBar")		# holds a reference to the boost UI bar
onready var ringCounter = get_node ("/root/Level/CanvasLayer/RingCounter")	# holds a reference to the ring counter UI item

onready var boostSound = find_node ("sound_boost")	# the audio stream player with the boost sound
onready var RailSound = find_node ("sound_rail")	# the audio stream player with the rail grinding sound
onready var voiceSound = find_node ("sound_voice")	# the audio stream player with the character's voices

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
var lRot := 0.0						# the player's rotation during the last frame
var start_position := Vector2.ZERO		# the position at which the player starts the level
var startLayer := 0.0				# the layer on which the player starts

var player_velocity := Vector2.ZERO	# the player's current velocity

var ground_velocity := 0.0		# the ground velocity
var previous_ground_velocity := 0.0	# the ground velocity during the previous frame

var backLayer := false	# whether or not the player is currently on the "back" layer

# Generic input that all player character will use.
func _input (_event: InputEvent) -> void:
	if (Input.is_action_just_pressed ("toggle_pause")):	# Pause the game?
		helper_functions.add_path_to_node ("res://Scenes/UI/menu_options.tscn", "/root/Level/CanvasLayer")
	# Movement direction can be anywhere between -1 (left) to +1 (right).
	movement_direction = (Input.get_action_strength ("move_right") - Input.get_action_strength ("move_left"))
	if (Input.is_action_pressed ("boost")):	# So long as boost is held down, increase the counter.
		is_boosting += (1 if boostBar.boostAmount > 0 else 0)
	else:									# No boosting, so reset to zero.
		is_boosting = 0
	is_stomping = (Input.is_action_just_pressed ("stomp") && !is_stomping)
	is_jumping = Input.is_action_pressed ("jump")
	is_crouching = Input.is_action_pressed ("ui_down")
	# reset using the dedicated reset button
	if Input.is_action_pressed ('restart'):
		reset_game ()
	return

### limitAngle
# Returns the given angle as an angle (in radians) between -PI and PI
func limitAngle (ang:float) -> float:
	var sign1 := 1.0
	if not ang == 0:
		sign1 = ang/abs (ang)
	ang = fmod (ang, PI*2)
	if abs (ang) > PI:
		ang = (2*PI-abs (ang))*sign1*-1
	return (ang)

### angleDist
# Returns the angle distance between rot1 and rot2, even over the 360deg mark.
# (i.e. 350 and 10 will be 20 degrees apart)
func angleDist (rot1:float, rot2:float) -> float:
	rot1 = limitAngle (rot1)
	rot2 = limitAngle (rot2)
	if abs (rot1-rot2) > PI and rot1>rot2:
		return (abs (limitAngle (rot1)-(limitAngle (rot2)+PI*2)))
	elif abs (rot1-rot2) > PI and rot1<rot2:
		return (abs ((limitAngle (rot1)+PI*2)-(limitAngle (rot2))))
	else:
		return abs (rot1-rot2)

### setCollisionLayer
# shortcut to change the collision mask for every raycast node connected to
# the player at the same time. Value is true for layer 1, false for layer 0
func setCollisionLayer (value) -> void:
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
	return

func _layer0 (area) -> void:
	# explicitly set the collision layer to 0
	print_debug ("layer0: ", area.name)
	setCollisionLayer (false)
	return

func _layer1 (area) -> void:
	# explicitly set the collision layer to 1
	print_debug ("layer1: ", area.name)
	setCollisionLayer (true)
	return

func _setVelocity (vel) -> void:
	player_velocity = vel
	return

func reset_game () -> void:
	reset_character ()
	if get_tree ().reload_current_scene () != OK:
		printerr ("ERROR: Could not reload current scene!")
		get_tree ().quit ()
	return

func reset_character () -> void:
	# reset your position and state if you pull a dimps (fall out of the world)
	player_velocity = Vector2.ZERO
	state = -1
	position = start_position
	setCollisionLayer (false)
	return

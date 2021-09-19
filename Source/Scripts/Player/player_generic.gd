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


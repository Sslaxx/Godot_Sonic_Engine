# controls "air furniture", such as springs, boost rings etc.

extends Area2D

# how strong is the spring?
export(float) var STRENGTH = 7
# does the spring force the player to go in the direction it is facing?
export(bool) var DIRECTED = false
# add a scaling effect (usually for boost rings)
export(bool) var ringScale = false

onready var animation = find_node ("AnimatedSprite")	# stores the animated sprite
onready var sound = find_node ("AudioStreamPlayer")		# stores the audio stream player
var scaling = 1	# stores the current scale of the spring

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_Area2D_area_entered")
	return

func _on_Area2D_area_entered (area) -> void:
	# if the player collides with the spring
	if area.name == "Player":

		# calculate what vector to launch Sonic in
		var launchVector := Vector2 (0, -STRENGTH).rotated (rotation)

		# calculate how fast sonic is moving perpendicularly to the spring
		var sideVector = area.player_velocity.dot (launchVector.normalized ().rotated (PI/2))\
				*launchVector.normalized ().rotated (PI/2)

		# calculate the final vector to throw sonic in. Ignore sideVector if 
		# the spring is directed
		var finalVector := (Vector2.ZERO if DIRECTED else sideVector) + launchVector

		# print out the values for debugging
		if (OS.is_debug_build ()):
			print ("sideVector: ", sideVector)
			print ("launchVector: ", launchVector)
			print ("finalVector: ", finalVector)

		# set sonic's velocity to the final vector
		area.player_velocity = finalVector
		# set sonic to the air state
		area.state = -1
		# Sonic didn't jump here...
		area.canShort = false
		# set Sonic's position to the spring's position
		area.position = position
		# if sonic stomped on to the spring, he is no longer stomping
		area.stomping = false

		# set sonic's sprite rotation to Sonic's rotation
		area.find_node ("PlayerSprites").rotation = area.rotation
		# reset sonic's rotation (this is typically how sonic works in the air)
		area.rotation = 0

		# set the spring's current animation frame to 0
		animation.frame = 0
		# play the spring sound
		sound.play ()
		# scale the spring (only applies if "ringScale" is enabled)
		scaling = 2
	return

func _process (_delta) -> void:
	# set and lerp scale if ringScale is enabled
	if (ringScale):
		scale = Vector2 (scaling, scaling)
		scaling = lerp (scaling, 1, 0.1)
	return

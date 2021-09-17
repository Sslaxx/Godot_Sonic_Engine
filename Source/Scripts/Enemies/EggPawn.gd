# this is the controller script for the basic egg pawn enemy. It is currently
# pretty basic, but I'll probably update it a bit more later

extends Area2D

export(PackedScene) var boostParticle

# is the egg pawn alive?
var alive := true

# How many hits does the enemy have left before being destroyed?
# TODO: Set this up!
export(int) var hits_left = 1

# keeps track of the pawn's velocity once it has "exploded"
var explode_velocity := Vector2.ZERO

# keeps a reference to the audio stream player for the explosion sound
onready var boomSound = get_node ("BoomSound")

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_EggPawn_area_entered")
	return

func _process (delta) -> void:
	if (alive):
		# a stupid simple AI routine. Simply move x by pixels per frame
		position.x -= abs (random_helpers.RNG.randf_range (delta, 0.1))
	else:
		# calculations for the explosion animation. 
		# Applies velocity, rotates, and then applies gravity
		position += explode_velocity
		rotation += 0.1
		explode_velocity.y += 0.2
	return

func _on_EggPawn_area_entered (area) -> void:
	# if the player collides with this egg pawn
	if (area.name == "Player" and alive):
		# if the player isn't attacking (boosting or jumping) hurt the player
		if (not area.isAttacking ()):
			area.hurt_player ()
			return
		elif (area.state == -1):
			# if it is attacking from the air, bounce it back up a bit 
			area.player_velocity.y = -5
		if (area.isAttacking ()):
			# Been hit, take damage.
#			get_node ("/root/Node2D/CanvasLayer/boostBar").changeBy (2)
			hits_left = hits_left - 1
			if (hits_left > 0):	# More than one hit remaining means the enemy survives.
				return

		# this robot is dead...
		alive = false
		var newNode = boostParticle.instance ()
		newNode.position = position
		newNode.boostValue = 2
		get_node ("/root/Node2D").add_child (newNode)

		# set the velocity to match Sonic's speed, with a few constraints
		explode_velocity = area.get ("player_velocity") * 1.5
		explode_velocity.y = min (explode_velocity.y, 10)
		explode_velocity.y -= 7

		# play the explosion sfx
		boomSound.play ()
	return

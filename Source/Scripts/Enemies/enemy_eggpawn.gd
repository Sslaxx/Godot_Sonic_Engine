# this is the controller script for the basic egg pawn enemy. It is currently pretty basic, but I'll probably update it a bit
# more later

extends "res://Scripts/Enemies/enemy_generic.gd"

# The basic pawn is updated every frame.
func _process (_delta) -> void:
	if (alive):
		# a stupid simple AI routine. Simply move x by pixels per frame
		position.x -= abs (random_helpers.RNG.randf_range (0.1, 0.5))
	else:
		# calculations for the explosion animation. 
		# Applies velocity, rotates, and then applies gravity
		position += explode_velocity
		rotation += 0.1
		explode_velocity.y += 0.2
		if (explode_velocity.y > 10):	# After a certain point, free them.
			queue_free ()
	return

# Something has hit the pawn?
func _on_enemy_area_entered (area) -> void:
	# if the player collides with this egg pawn
	if (area.name == "Player" && alive):
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
		get_node ("/root/Level").add_child (newNode)

		# set the velocity to match Sonic's speed, with a few constraints
		explode_velocity = area.get ("player_velocity") * 1.5
		explode_velocity.y = min (explode_velocity.y, 10)
		explode_velocity.y -= 7

		# play the explosion sfx
		sound_player.play_sound ("enemy_boom")
	return

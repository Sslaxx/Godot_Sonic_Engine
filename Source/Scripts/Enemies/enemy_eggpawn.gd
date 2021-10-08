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

### _on_enemy_area_entered
# Something has collided with this, what is it and what happens next?
func _on_enemy_area_entered (area) -> void:
	if (area is preload ("res://Scripts/Player/player_generic.gd") and alive):	# The player is hitting the egg pawn...
		# If the player isn't attacking, hurt the player.
		if (not area.is_player_attacking ()):
			area.hurt_player ()
			return
		elif (area.state == -1):	# Bounce a bit back into the air if attacking from above.
			area.player_velocity.y = -5
		if (area.is_player_attacking ()):	# Carry out the attack.
			hits_left = hits_left - 1
			if (hits_left > 0):	# More than one hit remaining means the enemy survives for now.
				return

		# This robot is dead...
		alive = false
		game_space.score += 100
		var newNode = boostParticle.instance ()
		newNode.position = position
		newNode.boostValue = 2
		get_node ("/root/Level").add_child (newNode)

		# Set the velocity to match Sonic's speed, with a few constraints.
		explode_velocity = area.get ("player_velocity") * 1.5
		explode_velocity.y = min (explode_velocity.y, 10)
		explode_velocity.y -= 7

		# Play the explosion sfx.
		sound_player.play_sound ("enemy_boom")
	return

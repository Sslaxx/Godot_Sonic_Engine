"""
this is the controller script for the basic egg pawn enemy. It is currently 
pretty basic, but I'll probably update it a bit more later
"""

extends Area2D

export(PackedScene) var boostParticle

# is the egg pawn alive?
var alive := true

# keeps track of the pawn's velocity once it has "exploded"
var splodeVel := Vector2.ZERO

# keeps a reference to the audio stream player for the explosion sound
var boomSound

func _ready() -> void:
	# get a reference to the explosion audio stream player node
	boomSound = get_node("BoomSound")
	return

func _process(delta) -> void:
	if alive:
		# a stupid simple AI routine. Simply move x by -delta pixels per frame
		position.x -= abs (delta);
	else:
		# calculations for the explosion animation. 
		# Applies velocity, rotates, and then applies gravity
		position += splodeVel
		rotation += 0.1
		splodeVel.y += 0.2
	return

func _on_EggPawn_area_entered(area) -> void:
	# if the player collides with this egg pawn
	if area.name == "Player" and alive:
		# if the player isn't attacking (boosting or jumping) hurt the player
		if not area.isAttacking():
			area.hurt_player()
		elif area.state == -1:
			# if it is attacking from the air, bounce it back up a bit 
			area.velocity1.y = -5
		if area.isAttacking():
#			get_node("/root/Node2D/CanvasLayer/boostBar").changeBy(2)
			var newNode = boostParticle.instance()
			newNode.position = position
			newNode.boostValue = 2
			get_node("/root/Node2D").add_child(newNode)

		# this robot is dead...
		alive = false

		# set the velocity to match Sonic's speed, with a few constraints
		splodeVel = area.get("velocity1")*1.5
		splodeVel.y = min(splodeVel.y,10)
		splodeVel.y -= 7

		# play the explosion sfx
		boomSound.play()
	return

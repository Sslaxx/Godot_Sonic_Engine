### enemy_generic.gd
# Generic script for all enemies.

extends Area2D

export(PackedScene) var boostParticle

# is the enemy alive?
var alive := true

# How many hits does the enemy have left before being destroyed?
export(int) var hits_left = 1

# keeps track of the pawn's velocity once it has "exploded"
var explode_velocity := Vector2.ZERO

# keeps a reference to the audio stream player for the explosion sound
onready var boomSound = get_node ("BoomSound")

func _ready () -> void:
	# The function that this refers to should be created in the actual scripts for enemies.
	helper_functions._whocares = self.connect ("area_entered", self, "_on_enemy_area_entered")
	return

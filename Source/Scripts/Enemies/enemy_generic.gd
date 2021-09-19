extends Area2D

export(PackedScene) var boostParticle

# is the enemy alive?
var alive := true

# How many hits does the enemy have left before being destroyed?
# TODO: Set this up!
export(int) var hits_left = 1

# keeps track of the pawn's velocity once it has "exploded"
var explode_velocity := Vector2.ZERO

# keeps a reference to the audio stream player for the explosion sound
onready var boomSound = get_node ("BoomSound")



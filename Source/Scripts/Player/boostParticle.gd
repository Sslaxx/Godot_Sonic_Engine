extends Node2D

var initialVel := Vector2.ZERO
var cVel := initialVel

export(float) var boostValue = 2

onready var player = get_node ("/root/Level/Player")
onready var hud_boost = get_node ("/root/Level/game_hud/hud_boost")

onready var line = get_node ("Line2D")
var lineLength := 30

var speed := 10.0

var oPos := Vector2.ZERO
var lPos := Vector2.ZERO

var timer := 0.0

func _ready () -> void:
	initialVel = Vector2 (random_helpers.RNG.randf ()-0.5, random_helpers.RNG.randf ()-0.5)
	initialVel = initialVel.normalized () * speed

	oPos = position
	lPos = oPos

	for i in range (lineLength):
		line.points [i] = Vector2.ZERO
	return

func _process (delta) -> void:
	if (timer < 1):
		timer += delta
	else:
		timer = 1
		speed += delta * 10

	cVel = initialVel.linear_interpolate ((player.position-position).normalized () * speed, timer)

	position = oPos.linear_interpolate (player.position, timer)

	oPos += initialVel

	for i in range (lineLength-1, 0, -1):
		line.points [i] = line.points [i-1]-(position-lPos)

	line.points [0] = Vector2.ZERO

	if (timer >= 1 && position.distance_to (player.position) <= speed):
		game_space.change_boost_value (boostValue)
		queue_free ()

	lPos = position
	return

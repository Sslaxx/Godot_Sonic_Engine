extends Node2D

var initialVel = Vector2.ZERO
var cVel = initialVel

export(float) var boostValue = 2

var player
var boostBar

var line 
var lineLength = 30

var speed = 10

var oPos
var lPos

var timer = 0

func _ready():
	initialVel = Vector2(random_helpers.RNG.randf()-0.5,random_helpers.RNG.randf()-0.5)
	initialVel = initialVel.normalized()*speed

	player = get_node("/root/Node2D/Player")
	boostBar = get_node("/root/Node2D/CanvasLayer/boostBar")

	line = get_node("Line2D")

	oPos = position
	lPos = oPos

	for i in range(lineLength):
		line.points[i] = Vector2(0,0)
	return

func _process(delta):
	if timer < 1:
		timer += delta
	else:
		timer = 1
		speed += delta*10

	cVel = initialVel.linear_interpolate((player.position-position).normalized()*speed,timer)

	position = oPos.linear_interpolate(player.position,timer)

	oPos += initialVel

	for i in range(lineLength-1,0,-1):
		line.points[i] = line.points[i-1]-(position-lPos)

	line.points[0] = Vector2(0,0)

	if timer >= 1 and position.distance_to(player.position) <= speed:
		boostBar.changeBy(boostValue)
		queue_free()

	lPos = position
	return

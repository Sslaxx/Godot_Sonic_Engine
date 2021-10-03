# Used to control the boost bar UI

extends Control

export(PackedScene) var barUnit

var barItems = []

export(float) var boostAmount = 20.0

export(bool) var infiniteBoost = false

var visualBar := 0.0

# Called when the node enters the scene tree for the first time.
func _ready () -> void:
	for i in range (20):
		barItems.append (barUnit.instance ())
		barItems [i].rect_position = Vector2 (0, -14*i-16)
		add_child (barItems [i])
	return

func _process (_delta) -> void:
	if (visualBar < boostAmount and visualBar <= 60):
		visualBar += 0.5
		barItems [floor (fmod (visualBar-2, 20))].rect_scale.x = 4
	else:
		visualBar = boostAmount

	# Make sure boost amount is kept within 0 to 60. If infinite boost is enabled, keep boost amount at maximum.
	boostAmount = (60.0 if infiniteBoost else clamp (boostAmount, 0.0, 60.0))
	$"/root/Level/game_hud/hud_boost".value = boostAmount

	var index := 0
	for i in barItems:
		index+=1
		var colorVal = floor (visualBar/20)+(1 if floor (fmod (visualBar, 20)) > index else 0)
		i.get_node ("TextureRect").rect_position.y = -24+8*colorVal
		i.rect_scale.x = lerp (i.rect_scale.x, 2, 0.2)
	return

# Change the current boost amount.
func changeBy (value:float) -> void:
	boostAmount += value
	return

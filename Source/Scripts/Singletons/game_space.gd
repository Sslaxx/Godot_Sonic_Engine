extends Node

var rings_collected:int = 0 setget set_rings
var real_rings_collected:int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	return

### change_boost_value
# Use this everywhere to change the current boost value.
func change_boost_value (change_to: float) -> void:
	$"/root/Level/game_hud/hud_boost".value += change_to
	return

func set_rings (value:int) -> void:
	if (value < rings_collected):
		print ("LOSE RINGS")
	else:
		print ("GAIN RINGS")
	rings_collected = value
	real_rings_collected = value
	$"/root/Level/game_hud/hud_rings/count".text = var2str (rings_collected)
	return

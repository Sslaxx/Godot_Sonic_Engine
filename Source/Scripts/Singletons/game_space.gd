extends Node

var rings_collected:int = 0 setget set_rings
var real_rings_collected:int = 0
var score:int = 0 setget set_score
var timer:Vector2 = Vector2.ZERO	# x represents seconds, y minutes.

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	helper_functions._whocares = $"level_timer".connect ("timeout", self, "on_level_timer_timeout")
	return

### change_boost_value
# Use this everywhere to change the current boost value.
func change_boost_value (change_to: float) -> void:
	$"/root/Level/game_hud/hud_boost".value += change_to
	return

### set_rings
# The setter for how many rings the player does (or doesn't) have.
func set_rings (value:int) -> void:
	if (value < rings_collected):
		print ("LOSE RINGS")
	else:
		print ("GAIN RINGS")
	rings_collected = value
	real_rings_collected = value
	$"/root/Level/game_hud/hud_rings/count".text = var2str (rings_collected)
	return

### on_level_timer_timeout
# This is called every second. It updates the timer display.
func on_level_timer_timeout () -> void:
	timer.x += 1
	if (timer.x > 59):	# A minute has passed!
		timer.x = 0
		timer.y += 1
	$"/root/Level/game_hud/hud_timer/count".text = var2str (int (timer.y)).pad_zeros (2) + ":" + var2str (int (timer.x)).pad_zeros(2)
	return

func set_score (value):
	score = value
	$"/root/Level/game_hud/hud_score/count".text = var2str (score)
	return

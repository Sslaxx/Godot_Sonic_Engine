extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	helper_functions._whocares = $"hud_boost".connect ("value_changed", self, "on_boost_hud_value_changed")
	return

### on_boost_hud_value_changed
# This function makes sure the boost bar is changed. If the infinite boost cheat is enabled, boost is kept at 60.
func on_boost_hud_value_changed (changed_to: float) -> void:
	$"hud_boost".value = (60.0 if game_space.infinite_boost_cheat else changed_to)
	return

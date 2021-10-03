extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	helper_functions._whocares = $"hud_boost".connect ("value_changed", self, "on_boost_hud_value_changed")
	return

func on_boost_hud_value_changed (changed_to: float) -> void:
	$"hud_boost".value = (60.0 if $"/root/Level/Player".infinite_boost_cheat else changed_to)
	return

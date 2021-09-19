### DeathPlane.gd
# Controls the "plane of death".

extends Area2D

func _ready () -> void:
	helper_functions._whocares = self.connect ("area_entered", self, "_on_DeathPlane_area_entered")
	return

### _on_DeathPlane_area_entered
# Something has entered the death plane, deal with it.
func _on_DeathPlane_area_entered (area) -> void:
	if area.name == "Player":
		area.resetGame ()
		if get_tree ().reload_current_scene () != OK:
			printerr ("ERROR: Could not reload current scene!")
			get_tree ().quit ()
	else:
		print (area.name, " has entered the death plane.")
		area.queue_free ()
	return

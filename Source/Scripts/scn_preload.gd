### The preloader script.
# This scene should just be used for (pre)loading stuff and then switching to the first "proper" scene of
# the program.
# This scene is (by default) a Node2D in case you want some kind of loading screen here.

extends Node2D

func _ready () -> void:
	print_debug (get_script ().resource_path, " ready. Node ", self, " (", self.name, ").")
	helper_functions._whocares = helper_functions.change_scene ("res://Scenes/Levels/level_test.tscn")
	return

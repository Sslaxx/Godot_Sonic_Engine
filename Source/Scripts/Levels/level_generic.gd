### level_generic.gd
# Sets up the generic patterns for a level.

extends Node2D
export(String, FILE, "*.ogg") var music_file	# Specify a file to be played.
export(Vector2) var starting_position = Vector2.ZERO

func _ready () -> void:
	if (music_file != ""):	# If there's a music file specified, play it.
		music_player.play_music (music_file)
	if (not has_node ("/root/Level/Player")):	# No player? Add them to the scene.
		helper_functions.add_path_to_node ("res://Scenes/Player/player_sonic.tscn", "/root/Level")
		game_space.last_checkpoint = starting_position	# Set the initial start position.
	return

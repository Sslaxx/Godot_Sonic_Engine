### level_generic.gd
# Sets up the generic patterns for a level.

extends Node2D
export(String, FILE, "*.ogg") var music_file	# Specify a file to be played.

func _ready () -> void:
	if (music_file != ""):	# If there's a music file specified, play it.
		music_player.play_music (music_file)
	if (not has_node ("/root/Level/Player")):	# No player? Add them to the scene.
		helper_functions.add_path_to_node ("res://Scenes/Player/player_sonic.tscn", "/root/Level")
		yield (get_tree (), "idle_frame")		# And make sure they're added before continuing...
	if (has_node ("/root/Level/start_point")):	# We have a starting checkpoint!
		$"/root/Level/start_point".passed_checkpoint = true
		$"/root/Level/Player".position = $"/root/Level/start_point".position
		game_space.last_checkpoint = $"/root/Level/start_point"
	else:
		printerr ("You shouldn't see this - did you forget to set start_point?")
		game_space.player_node.position = Vector2.ZERO
	return

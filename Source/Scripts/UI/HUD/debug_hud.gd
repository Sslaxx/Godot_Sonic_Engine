### debug_hud.gd
# Displays assorted information that's useful while debugging.
# As this runs constantly, it only gets added to the scene when in debug mode.

extends CanvasLayer

func _ready () -> void:
	if (not OS.is_debug_build ()):		# If not running in debug mode, remove this.
		queue_free ()
	return

func _process (_delta) -> void:
	$"Position".text = "POSITION: " + var2str (int (game_space.player_node.position.x)) + ", " + \
		var2str (int (game_space.player_node.position.y))
	$"Velocity".text = "VELOCITY: " + var2str (game_space.player_node.player_velocity.x).pad_decimals (1) + ", " + \
		var2str (game_space.player_node.player_velocity.y).pad_decimals (1)
	$"FPS".text = "FPS: " + var2str (Engine.get_frames_per_second ())
	$"Rotation".text = "ROTATION: " + var2str (rad2deg (game_space.player_node.rotation)).pad_decimals (2) + "°"
	$"Boosting".text = "BOOSTING: " + ("YES" if game_space.player_node.is_boosting > 0 else "NO")
	$"Crouching".text = "CROUCHING: " + ("YES" if game_space.player_node.is_crouching else "NO")
	$"Flying".text = "FLYING: " + ("YES" if game_space.player_node.is_flying else "NO")
	$"Gliding".text = "GLIDING: " + ("YES" if game_space.player_node.is_gliding else "NO")
	$"Grinding".text = "GRINDING: " + ("YES" if game_space.player_node.is_grinding else "NO")
	$"Jumping".text = "JUMPING: " + ("YES" if game_space.player_node.is_jumping else "NO")
	$"Rolling".text = "ROLLING: " + ("YES" if game_space.player_node.is_rolling else "NO")
	$"Spindashing".text = "SPINDASHING: " + ("YES" if game_space.player_node.is_spindashing else "NO")
	$"Stomping".text = "STOMPING: " + ("YES" if game_space.player_node.is_stomping else "NO")
	$"Tricking".text = "TRICKING: " + ("YES" if game_space.player_node.is_tricking else "NO")
	$"Unmoveable".text = "UNMOVEABLE: " + ("YES" if game_space.player_node.is_unmoveable else "NO")
	return

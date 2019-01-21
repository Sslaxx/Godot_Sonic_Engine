"""
   This file is part of:
   GODOT SONIC ENGINE

   Copyright (c) 2018- Stuart Moore.

   Licenced under the terms of the MIT "expat" license.

   Permission is hereby granted, free of charge, to any person obtaining
   a copy of this software and associated documentation files (the
   "Software"), to deal in the Software without restriction, including
   without limitation the rights to use, copy, modify, merge, publish,
   distribute, sublicense, and/or sell copies of the Software, and to
   permit persons to whom the Software is furnished to do so, subject to
   the following conditions:

   The above copyright notice and this permission notice shall be
   included in all copies or substantial portions of the Software.

   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

"""
   The debugging HUD layer. Whatever information is considered useful is put on this layer.

   As this gets called every frame it could potentially eat up a lot of processing power. This should only ever be instantiated
   by the level_generic.gd script if OS.is_debug_build is true.
"""

extends CanvasLayer

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Debugging HUD ready on canvas layer ", layer, ".")
	else:
		queue_free ()	# This shouldn't be used if debugging isn't on, so delete it from the scene tree.
	return

func _process (delta):
	if (game_space.player_character == null):	# No player character, no point in updating!
		return
	var prettied_text = ""	# Used for formatting the text for the labels.
	# First up, show the frames per second.
	prettied_text = "FPS: " + var2str (int (Engine.get_frames_per_second ()))
	$FPS.text = prettied_text
	# How fast is the player character moving?
	prettied_text = "SPEED: " + var2str (int (game_space.player_character.player_speed))
	$Speed.text = prettied_text
	# What direction?
	prettied_text = "DIRECTION: " + game_space.player_character.moving_in
	$Direction.text = prettied_text
	# What's the velocity?
	prettied_text = "VELOCITY: " + var2str (int (game_space.player_character.velocity.x))
	prettied_text += ", " + var2str (int (game_space.player_character.velocity.y))
	$Velocity.text = prettied_text
	# And where are they in the scene?
	prettied_text = "POSITION: " + var2str (int (game_space.player_character.position.x))
	prettied_text += ", " + var2str (int (game_space.player_character.position.y))
	$Position.text = prettied_text
	# Are they jumping?
	prettied_text = "JUMPING: "
	prettied_text += ("True" if (game_space.player_character.player_movement_state & game_space.player_character.MovementState.STATE_JUMPING) else "False")
	$Jumping.text = prettied_text
	prettied_text = "ON FLOOR: "
	prettied_text += ("True" if game_space.player_character.is_on_floor () else "False")
	$On_Floor.text = prettied_text
	prettied_text = "ANIMATION: " + game_space.player_character.get_node ("AnimatedSprite").animation
	$Animation.text = prettied_text
	prettied_text = "FLOOR SNAP: " + var2str (int (game_space.player_character.floor_snap.x))
	prettied_text += ", " + var2str (int (game_space.player_character.floor_snap.y))
	$"Floor_Snap".text = prettied_text
	return

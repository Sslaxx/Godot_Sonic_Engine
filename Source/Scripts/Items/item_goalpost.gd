### This file is part of:
#   GODOT SONIC ENGINE

#   Copyright (c) 2019- Stuart Moore.

#   Licenced under the terms of the MIT "expat" license.

#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:

#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.

#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Controls the "goalpost" - the end of the current level.
# When it's touched, it'll play an animation. Once that animation has finished, it'll do the end-of-level stuff.

extends Area2D

var goaled:bool = false

# Called when the node enters the scene tree for the first time.
func _ready () -> void:
	helper_functions._whocares = self.connect ("body_entered", self, "hit_goalpost")
	helper_functions._whocares = $"AnimationPlayer".connect ("animation_finished", self, "goalpost_raised")
	return

### hit_goalpost
# Called when something passes by the goalpost. If it's the player, then it'll trigger the end-of-level sequence.
# This handles the end-of-level animation, everything else should be handled by goalpost_raised.
func hit_goalpost (body) -> void:
	if (body is preload ("res://Scripts/Player/player_generic.gd") && !goaled):	# Player has passed the goalpost.
		goaled = true
		$"AnimationPlayer".play ("goal")
		$"AudioStreamPlayer".play ()
		if (OS.is_debug_build ()):
			printerr ("Goal post passed!")
	return

### goalpost_raised
# Once the end-of-level animation has been played, start with everything else.
func goalpost_raised (_xxx) -> void:
	printerr ("TODO: End of level stuff here!")
	game_space.player_character.player_movement_state = game_space.player_character.MovementState.STATE_CUTSCENE
	return

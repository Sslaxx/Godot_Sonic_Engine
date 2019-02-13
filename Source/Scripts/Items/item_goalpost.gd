"""
   This file is part of:
   GODOT SONIC ENGINE

   Copyright (c) 2019- Stuart Moore.

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
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

"""
   Controls the "goalpost" - the end of the current level.

   When it's touched, it'll play an animation. Once that animation has finished, it'll do the end-of-level stuff.
"""

extends Area2D

var goaled:bool = false

# Called when the node enters the scene tree for the first time.
func _ready ():
	self.connect ("body_entered", self, "hit_goalpost")
	$"AnimationPlayer".connect ("animation_finished", self, "goalpost_raised")
	return

func hit_goalpost (body):
	if (body is preload ("res://Scripts/Player/player_generic.gd") && !goaled):	# Player has passed the goalpost.
		goaled = true
		$"AnimationPlayer".play ("goal")
		$"AudioStreamPlayer".play ()
		game_space.player_character.player_movement_state = game_space.player_character.MovementState.STATE_CUTSCENE
		if (OS.is_debug_build ()):
			printerr ("Goal post passed!")
	return

func goalpost_raised (xxx):
	print ("TODO: End of level stuff here!")
	return

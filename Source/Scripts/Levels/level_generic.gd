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
   This is the generic level code. All levels extend from this script. It handles all the generica that's common between levels -
   starting and ending, checkpoints, which player character to use etc.
"""

extends Node2D

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Ensure the debug HUD is added to the scene.
		printerr ("Generic level functionality ready.")
		global_space.add_path_to_node ("res://Scenes/UI/debug_hud_layer.tscn", "/root/Level")
	# Add the HUD to the scene.
	global_space.add_path_to_node ("res://Scenes/UI/hud_layer.tscn", "/root/Level")
	game_space.get_node ("Timer").start ()	# Start the level timer.
	return

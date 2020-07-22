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
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

"""
   Just the script to the test level, to make sure scripts are working as they should. Normally this type of script would handle
   things specific to a level.

   All these scripts MUST inherit from level_generic.gd, which in turn inherits from Node2D.
"""

extends "res://Scripts/Levels/level_generic.gd"

func _ready () -> void:
	if (OS.is_debug_build ()):
		global_space.add_path_to_node ("res://Scenes/Player/player_sonic.tscn", "/root/Level")
	return

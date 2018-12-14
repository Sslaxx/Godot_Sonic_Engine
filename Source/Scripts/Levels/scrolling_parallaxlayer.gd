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
   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.*/
   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
"""

"""
   Makes a ParallaxLayer scroll on its own. It can move x and/or y-axis independently.
   To use:
   1 - Attach this script to a (properly configured!) ParallaxLayer node/scene.
   2 - Use the "Movement Factor" property in the inspector to set the speed/direction required (x direction, y direction).
"""

extends ParallaxLayer

export var movement_factor = Vector2 (0, 0)	# Have movement be able to be changed in the object inspector.

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Give a bit of info about what is moving how.
		print (name, " is moving at ", movement_factor, ".")
	return

"""
   Make the layer move!
"""
func _process (delta):
	motion_offset += (movement_factor * delta)	# Move the background, in the directions and speed required.
	return

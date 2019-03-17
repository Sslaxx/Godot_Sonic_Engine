"""
   This file is part of:
   GODOT SONIC ENGINE

   Copyright (c) 2019- Stuart Moore.

   Originally from the Godot 2D platformer demo.
   Copyright (c) 2007-2019 Juan Linietsky, Ariel Manzur.
   Copyright (c) 2014-2019 Godot Engine contributors.

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
   Taken from the Godot demo suite, this implements a moving platform that allows both x and y movement.
   Motion is a range, remember. So (0, 100) moves -50<-0->+50 in the y-axis.
   Cycle determines how fast it moves; higher values are faster.
"""

extends Node2D

export var motion = Vector2.ZERO	# The range of movement that the platform moves around with.
export var cycle: float = 1.0		# Controls the speed of movement.
var accum: float = 0.0

func _ready () -> void:
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Moving platform at ", position, " ready. Moving in ", motion, " range and at ", cycle, " speed.")
	return

func _physics_process (delta: float) -> void:
	accum += delta * (1.0 / cycle) * PI * 2.0
	accum = fmod (accum, PI * 2.0)
	var d: float = sin (accum)
	var xf = Transform2D ()
	xf [2] = motion * d
	$platform.transform = xf
	return

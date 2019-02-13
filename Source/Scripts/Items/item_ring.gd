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

### Rings (aka collectibles).

extends Area2D

var ring_taken: bool = false

func _ready () -> void:
	self.connect ("body_entered", self, "got_ring")
	$"AudioStreamPlayer".connect ("finished", self, "ring_got")
	return

"""
   This is called whenever some PhysicsBody2D item enters the area that the ring is in.

   If the body that enters the area is a player character, the item is collected.
"""
func got_ring (body) -> void:
	if (!ring_taken && body is preload ("res://Scripts/Player/player_generic.gd")):
		ring_taken = true				# The player has picked up the ring! So make sure this ring is set as taken.
		visible = false					# And then as invisible, because of playing the sound.
		game_space.collectibles += 1	# Increase the player's rings count.
		$"AudioStreamPlayer".play ()	# And play the collected sound effect.
	return

# This doesn't do anything except remove the ring from the scene tree once the sound has finished playing.
func ring_got () -> void:
	if (OS.is_debug_build()):	# FOR DEBUGGING ONLY.
		printerr ("Ring collected at ", position, ".")	# Report where the ring taken had been.
	queue_free ()										# Remove the ring from the scene tree.
	return

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

### The checkpoint script.
# If the player dies, they are either reset to the start position, or the last checkpoint they passed by. This makes it happen.

extends Area2D

var taken:bool = false

func _ready () -> void:
	$"Sprite/AnimationPlayer".play ("spin_red")
	self.connect ("body_entered", self, "enter_checkpoint_body")
	return

"""
   enter_checkpoint_body

   The checkpoint has been passed by, so set positions and play animations as required.
"""
func enter_checkpoint_body (body) -> void:
	if (!taken && body is preload ("res://Scripts/Player/player_generic.gd")):
		# The player has passed the checkpoint, change the animation and set the last_checkpoint variable to this checkpoint.
		taken = true	# A checkpoint can only be activated once.
		if (OS.is_debug_build()):	# FOR DEBUGGING ONLY.
			print ("Checkpoint at ", position, " crossed.")
		$"Sprite/AnimationPlayer".play_backwards ("spin_green")
		game_space.last_checkpoint = self
		$"AudioStreamPlayer2D".play ()	# Play the checkpoint jingle.
	return

"""
   return_to_checkpoint

   As it says, returns the player character to this checkpoint. Also resets their rotation and their state to idle.
"""
func return_to_checkpoint () -> void:
	game_space.player_character.position = position
	game_space.player_character.rotation = 0
	game_space.player_character.player_movement_state = game_space.player_character.MovementState.STATE_IDLE
	game_space.player_character.visible = true
	return

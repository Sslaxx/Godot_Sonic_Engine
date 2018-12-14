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
   This is the generic player code. All player characters extend from this script. It handles all the generica that's common
   between them, primarily movement.
"""

extends KinematicBody2D

"""
   Movement variables - those for moving the player, how much to move the player by, how they affect the player moving.
   Remember that all of these are defined using pixels per second as measurement.
"""

## MOVING THE PLAYER.

# Controlling the current movement state of the player character.
enum MovementState {
	STATE_IDLE = 0,	# Player is not moving.
	STATE_MOVE_LEFT = 1,
	STATE_MOVE_RIGHT = 2,
	STATE_JUMPING = 4,
	STATE_CROUCHING = 8,
	STATE_SPINNING = 16,
	STATE_CUTSCENE = 32,
}

var player_state = MovementState.STATE_IDLE	# The current state the player character is in.
var moving_in = "nil"	# Which direction the player is holding down, i.e. the direction the player is going to move in.
var movement_direction = 0	# Which direction the player is currently moving in. -1 = left/up, 1 = right/down.
var player_speed = 0.0	# The speed at which the player is moving at.

var velocity = Vector2 (0, 0)	# The velocity (amount the player is moving in a direction).

## HOW MUCH TO MOVE THE PLAYER.

# The "gravity" that affects the player, in terms of both speed and direction.
# Normally, adjust the project settings (under Physics/2D) to alter these.
onready var player_gravity = ProjectSettings.get_setting ("physics/2d/default_gravity")

## AFFECTING THE PLAYER MOVING.

var floor_normal = Vector2 (0, -1)	# Vector to use for floor detection.

onready var player_gravity_vector = ProjectSettings.get_setting ("physics/2d/default_gravity_vector")	# Gravity's direction.

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Ensure the debug HUD is added to the scene.
		printerr ("Generic player functionality ready.")
	game_space.player_character = $"."	# Make sure the game knows which character to deal with!
	return

func _input (event):
	# First things first: find out which direction the player is moving in.
	moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))
	# Set the movement state and direction as required.
	match (moving_in):
		"left":
			player_state |= STATE_MOVE_LEFT
			player_state &= ~STATE_MOVE_RIGHT
			movement_direction = -1
		"right":
			player_state |= STATE_MOVE_RIGHT
			player_state &= ~STATE_MOVE_LEFT
			movement_direction = 1
		"nil":
			if (player_speed < 0.01 && (player_state & STATE_MOVE_LEFT || player_state & STATE_MOVE_RIGHT)):
				player_state = STATE_IDLE
				movement_direction = 0
	return

func _process (delta):
	return

func _physics_process (delta):
	if (movement_direction == -1 && moving_in == "left"):
		player_speed += 1
	if (movement_direction == -1 && moving_in == "right"):
		player_speed -=1
	if (movement_direction == 1 && moving_in == "right"):
		player_speed += 1
	if (movement_direction == 1 && moving_in == "left"):
		player_speed -= 1
	if (movement_direction != 0 && moving_in == "nil"):
		player_speed -=1
	player_speed = (0 if player_speed < 0 else player_speed)
	print (player_speed, " ", movement_direction, " ", moving_in)
	return

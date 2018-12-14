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

# Acceleration, deceleration and speed limits. These can be adjusted in the player scene directly.
export var acceleration_rate = 2	# Standard rate of acceleration.
export var decel_rate_moving = 6	# Decelerating rate when moving in the other direction.
export var decel_rate = 2			# Deceleration rate (not moving).
export var max_speed = 60			# Default maximum speed is 60 pixels per second.

## AFFECTING THE PLAYER MOVING.

var floor_normal = Vector2 (0, -1)	# Vector to use for floor detection.

onready var player_gravity_vector = ProjectSettings.get_setting ("physics/2d/default_gravity_vector")	# Gravity's direction.

"""
   Variables that control animation - like when to play walk/jog/run animations.
"""

# Limits for changing between walk/jog/run animations - MUST BE SET IN THE CHARACTER SCENE.
export var walk_limit = 0
export var jog_limit = 0
export var run_limit = 0

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
		"right":
			player_state |= STATE_MOVE_RIGHT
			player_state &= ~STATE_MOVE_LEFT
		"nil":
			if (player_speed < 0.01 && (player_state & STATE_MOVE_LEFT || player_state & STATE_MOVE_RIGHT)):
				player_state = STATE_IDLE
				movement_direction = 0
	return

func _process (delta):
	return

func _physics_process (delta):
	$AnimatedSprite.flip_h = (true if movement_direction == -1 else (false if movement_direction == 1 else $AnimatedSprite.flip_h))
	match (movement_direction):	# Make the player move faster (or slower) depending on what direction they're in.
		-1:
			if (moving_in == "left"):
				player_speed += acceleration_rate
			elif (moving_in == "right"):
				player_speed -= decel_rate_moving
		1:
			if (moving_in == "right"):
				player_speed += acceleration_rate
			elif (moving_in == "left"):
				player_speed -= decel_rate_moving
	if (movement_direction != 0 && moving_in == "nil"):
		player_speed -= decel_rate
	player_speed = (0 if player_speed < 0 else (max_speed if player_speed > max_speed else player_speed))
	if (player_speed < 0.01):	# The player has stopped, so do we need to change movement direction?
		if ((player_state & STATE_MOVE_LEFT) && moving_in == "left"):	# Yes, to the left.
			movement_direction = -1
		if ((player_state & STATE_MOVE_RIGHT) && moving_in == "right"):	# Yes, to the right.
			movement_direction = 1
		if (moving_in == "nil"):										# No, so set idle.
			player_state = STATE_IDLE
			movement_direction = 0
	if (player_speed > 0):
		if (player_speed < walk_limit):
			change_anim ("walk")
		if (player_speed >= walk_limit && player_speed < jog_limit):
			change_anim ("jog")
		if (player_speed >= jog_limit):
			change_anim ("run")
	else:
			change_anim ("idle")
	printerr (player_speed, " ", movement_direction, " ", moving_in, " ", player_state)
	return

"""
   change_anim
   change_anim (anim_to_change_to):

   Chnges the animation playing to anim_to_change_to, if it isn't already playing.
"""
func change_anim (anim_to_change_to):
	if ($AnimatedSprite.animation == anim_to_change_to):	# Animation's already playing, so return.
		return
	$AnimatedSprite.play (anim_to_change_to)				# Change the animation to the one requested.
	return

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

var player_movement_state = MovementState.STATE_IDLE	# The current moving state the player character is in.
var moving_in = "nil"		# Which direction the player is holding down, i.e. the direction the player is (going) to move in.
var movement_direction = 0	# Which direction the player is currently moving in. -1 = left/up, 1 = right/down.
var player_speed = 0.0		# The speed at which the player is moving at.
#var jump_amount = 0			# How much the player is (going to) jump by.
#var jump_held = false		# Is the jump button being held down?
#var jump_direction = 0		# In which direction is the jump currently going in? -1 = up, 1 = down.

var velocity = Vector2 (0, 0)	# The velocity (amount the player is moving in a direction).

## HOW MUCH TO MOVE THE PLAYER.

# The "gravity" that affects the player, in terms of both speed and direction.
# Normally, adjust the project settings (under Physics/2D) to alter these.
onready var player_gravity = ProjectSettings.get_setting ("physics/2d/default_gravity")

# Acceleration, deceleration and speed limits. These can be adjusted in the player scene directly.
export var acceleration_rate = 4	# Standard rate of acceleration.
export var decel_rate_moving = 6	# Decelerating rate when moving in the other direction.
export var decel_rate = 4			# Deceleration rate (not moving).
export var max_speed = 60			# Default maximum speed is 60 pixels per second.
#export var jump_adding = 3			# How much to add to jump for each "tick" jump is held down by.
#export var jump_max = 90			# How much the player can jump by at maximum.
#export var jump_speed = 3			# How "fast" the player jumps a frame.

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
	change_anim ("idle")				# Ensure some kind of animation is playing when instanced.
	return

func _input (event):
	# Find out which direction the player is moving in.
	moving_in = ("left" if Input.is_action_pressed ("move_left") else ("right" if Input.is_action_pressed ("move_right") else "nil"))
#	if (Input.is_action_just_pressed ("move_jump")):	# The player is jumping (pressed the jump button).
#		if (!player_movement_state & MovementState.STATE_JUMPING):
#			jump_held = true
#			player_movement_state |= MovementState.STATE_JUMPING
#	if (Input.is_action_just_released ("move_jump" && jump_held)):	# The jump button has been released.
#		jump_held = false
	# Unless there's a cutscene playing, in which case negate any and all movement.
	if (player_movement_state & MovementState.STATE_CUTSCENE):
		moving_in = "nil"
#		jump_held = false
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Debug keys and what they do.
		if (Input.is_action_pressed ("DEBUG_gainrings")):	# Gain items!
			game_space.collectibles += 10
		if (Input.is_action_pressed ("DEBUG_loserings")):	# Lose items!
			game_space.collectibles = 0
	return

func _process (delta):
	return

func _physics_process (delta):
	# Do state machine checks here.
	movement_state_machine (delta)	# For movement.
	if (is_on_floor ()):
		movement_state_machine_ground (delta)	# And being on the ground.
	else:
		movement_state_machine_air (delta)		# And being in the air.
	velocity.x = (player_speed * movement_direction)	# Work out velocity from speed * direction.
	velocity = move_and_slide (velocity, floor_normal)
	return

"""
   change_anim
   change_anim (anim_to_change_to):

   Changes the animation playing to anim_to_change_to, if it isn't already playing.
"""
func change_anim (anim_to_change_to):
	if (!has_node ("AnimatedSprite")):			# Can't play animations without something to play with!
		printerr ("Trying to play without an AnimatedSprite node for the player character!")
		return
	if ($AnimatedSprite.animation != anim_to_change_to):	# Animation's not already playing?
		$AnimatedSprite.play (anim_to_change_to)			# So change the animation to the one requested.
	return

### STATE MACHINE FUNCTIONS.

"""
   movement_state_machine

   The basic movement state logic goes in here. Sets movement direction based on movement state.
"""
func movement_state_machine (delta):
	match (moving_in):		# Set the movement state and direction as required.
		"left":
			player_movement_state |= MovementState.STATE_MOVE_LEFT
			player_movement_state &= ~MovementState.STATE_MOVE_RIGHT
		"right":
			player_movement_state |= MovementState.STATE_MOVE_RIGHT
			player_movement_state &= ~MovementState.STATE_MOVE_LEFT
	if (player_movement_state & MovementState.STATE_MOVE_LEFT):	# All the left-moving logic goes in here.
		if (moving_in == "left"):			# Player is moving left.
			movement_direction = (-1 if player_speed < 0.01 else movement_direction)
	if (player_movement_state & MovementState.STATE_MOVE_RIGHT):	# All the right-moving logic goes in here.
		if (moving_in == "right"):			# Player is moving right.
			movement_direction = (1 if player_speed < 0.01 else movement_direction)
	return

"""
   movement_state_machine_ground

   Sets movement direction according to player input, and does that based upon the current movement state. Also changes
   animations. Called when the player character is on the ground (is_on_floor is true).
"""
func movement_state_machine_ground (delta):
	if (player_movement_state & MovementState.STATE_JUMPING):	# Finished jumping? Turn off the jump state.
		player_movement_state &= ~MovementState.STATE_JUMPING
	if ((player_movement_state & MovementState.STATE_MOVE_LEFT) && movement_direction == 1):
		player_speed -= decel_rate_moving	# Wanting to move left but currently moving right, so decelerate.
	if ((player_movement_state & MovementState.STATE_MOVE_RIGHT) && movement_direction == -1):
		player_speed -= decel_rate_moving	# Wanting to move right but currently moving left, so decelerate.
	if (moving_in == "nil" && movement_direction != 0):	# Still moving, but no movement input has been given.
		player_speed -= decel_rate	# So slow down.
	player_speed += (acceleration_rate if moving_in != "nil" else 0)	# If the player is moving, accelerate.
	# Ensure the player's speed is limited appropriately.
	player_speed = (0 if player_speed < 0 else (max_speed if player_speed > max_speed else player_speed))
	# Set direction for animations to play as appropriate.
	$AnimatedSprite.flip_h = (true if movement_direction == -1 else (false if movement_direction == 1 else $AnimatedSprite.flip_h))
	# Change the currently playing animation based on the player's current speed...
	if (player_speed > 0):
		if (player_speed < walk_limit):
			change_anim ("walk")
		if (player_speed >= walk_limit && player_speed < jog_limit):
			change_anim ("jog")
		if (player_speed >= jog_limit):
			change_anim ("run")
	else:	# ...or lack of it.
		if (!player_movement_state & MovementState.STATE_CUTSCENE):	# If a cutscene is running, changing animation is handled differently.
			change_anim ("idle")
			player_movement_state = MovementState.STATE_IDLE
		movement_direction = 0
	return

"""
   movement_state_machine_air

   Does state machine checks while the player is in the air, either jumping or falling.
"""
func movement_state_machine_air (delta):
	if (!player_movement_state & MovementState.STATE_JUMPING):	# We're not jumping, so we're falling!
		velocity.y = player_gravity + acceleration_rate			# So we're falling by the rate of gravity.
	if ((player_movement_state & MovementState.STATE_MOVE_LEFT) && movement_direction == 1):
		player_speed -= decel_rate_moving	# Wanting to move left but currently moving right, so decelerate.
	if ((player_movement_state & MovementState.STATE_MOVE_RIGHT) && movement_direction == -1):
		player_speed -= decel_rate_moving	# Wanting to move right but currently moving left, so decelerate.
	if (moving_in == "nil" && movement_direction != 0):	# Still moving, but no movement input has been given.
		player_speed -= decel_rate	# So slow down.
	player_speed += (acceleration_rate if moving_in != "nil" else 0)	# If the player is moving, accelerate.
	# Set direction for animations to play as appropriate.
	$AnimatedSprite.flip_h = (true if movement_direction == -1 else (false if movement_direction == 1 else $AnimatedSprite.flip_h))
	player_speed = (0 if player_speed < 0 else (max_speed if player_speed > max_speed else player_speed))
	# Change the currently playing animation based on the player's current speed...
	if (player_speed > 0 && !(player_movement_state & MovementState.STATE_JUMPING)):	# Not jumping, so animations can change.
		if (player_speed < walk_limit):
			change_anim ("walk")
		if (player_speed >= walk_limit && player_speed < jog_limit):
			change_anim ("jog")
		if (player_speed >= jog_limit):
			change_anim ("run")
	return
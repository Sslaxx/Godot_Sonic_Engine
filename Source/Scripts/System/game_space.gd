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
   Game(play) related functions and variables that are used throughout the entire game.
   Also certain things (like timers) that are used globally.
"""

extends Node

const DEFAULT_LIVES = 3						# Default number of lives the player starts with.
const DEFAULT_TIME_LIMIT = 10				# Time limit per level; defaults to 10 minutes.
const DEFAULT_COLLECTIBLES_PER_LIFE = 100	# How many collectibles to collect to get an extra life.

## VARIABLES THAT DO NOT NEED RESETTING ON GAME RESTART.

## VARIABLES THAT WILL NEED TO BE RESET ON GAME RESTART.

var level_time = Vector2 (0, 0)	# Time passed in the level so far. x is minutes, y seconds.
var lives = DEFAULT_LIVES setget set_lives, get_lives			# Controls the lives the player has.
var score = 0 setget set_score, get_score						# What the player's score is.
var collectibles = 0 setget set_collectibles, get_collectibles	# The collectibles the player has.
var collectibles_lives = 0										# Used to keep track of items for lives.

onready var player_character = null		# Who is the player character? Set up by player_<character name>.gd script in its _ready.
onready var last_checkpoint = null		# The last checkpoint passed by the player.

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Game-space ready.")
	$Timer.connect ("timeout", self, "update_level_timer")
	return

"""
   update_hud

   Updates the in-game HUD (if it's there to update) by calling its hud_layer_update function.

   This is called mainly by the setters. It's also called by timer signals. ONLY this function should be used by any function
   that needs to update the HUD.
"""
func update_hud ():
	if (has_node ("/root/Level/hud_layer")):
		$"/root/Level/hud_layer".hud_layer_update ()
	return

"""
   update_level_timer

   Updates the current time in the level.
"""
func update_level_timer ():
	# Only update the timer if a cutscene is not playing.
	if (!(player_character.player_movement_state == player_character.MovementState.STATE_CUTSCENE)):
		level_time.y += 1			# Add one second to the timer.
		if (level_time.y > 59):		# Is it over a minute?
			level_time.y = 0		# If so, reset the seconds timer.
			level_time.x += 1		# And increase the minutes timer.
		update_hud ()
	return

"""
   reset_game_space

   As singletons are not reset by restarting an application, they have to be handled manually.
"""
func reset_game_space ():
	level_time = Vector2 (0, 0)
	lives = DEFAULT_LIVES
	score = 0
	collectibles = 0
	collectibles_lives = 0
	player_character = null
	last_checkpoint = null
	return

### SETTERS AND GETTERS.

## For the lives.

# Should handle most death, dying and extra life notifications as required.
func set_lives (value):
	lives = value
	update_hud ()
	return

func get_lives ():
	return (lives)

## For the collectibles.

# Handles collecting items, and what to do when a certain number is reached if anything.
func set_collectibles (value):
	if (value > collectibles):		# Collected something, so add what the difference is to the items-for-lives-counter.
		collectibles_lives += (value - collectibles)
	else:							# Lost items, so set the items-for-lives-counter to the new value.
		collectibles_lives = value
	collectibles = value
	while (collectibles_lives >= DEFAULT_COLLECTIBLES_PER_LIFE):	# Collected enough for at least one extra life!
		game_space.lives += 1
		collectibles_lives -= DEFAULT_COLLECTIBLES_PER_LIFE
	update_hud ()
	return

func get_collectibles ():
	return (collectibles)

## For score.

func set_score (value):
	score = value
	update_hud ()
	return

func get_score ():
	return (score)

### This file is part of:
#   GODOT SONIC ENGINE

#   Copyright (c) 2019- Stuart Moore.

#   Licenced under the terms of the MIT "expat" license.

#   Permission is hereby granted, free of charge, to any person obtaining
#   a copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:

#   The above copyright notice and this permission notice shall be
#   included in all copies or substantial portions of the Software.

#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
#   EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

### Game(play) related functions and variables that are used throughout the entire game.
# Also certain things (like timers) that are used globally.

extends Node

const DEFAULT_LIVES:int = 3						# Default number of lives the player starts with.
const DEFAULT_TIME_LIMIT:int = 10				# Time limit per level; defaults to 10 minutes.
const DEFAULT_COLLECTIBLES_PER_LIFE:int = 100	# How many collectibles to collect to get an extra life.

## VARIABLES THAT DO NOT NEED RESETTING ON GAME RESTART.

## VARIABLES THAT NEED TO BE RESET ON GAME RESTART.

var level_time:Vector2 = Vector2.ZERO	# Time passed in the level so far. x is minutes, y seconds.
var lives:int = DEFAULT_LIVES setget set_lives, get_lives			# Controls the lives the player has.
var score:int = 0 setget set_score, get_score						# What the player's score is.
var collectibles:int = 0 setget set_collectibles, get_collectibles	# The collectibles the player has.
var collectibles_lives:int = 0										# Used to keep track of items for lives.

onready var player_character = null		# Will normally point to res://Scenes/Player/player_character.tscn
onready var last_checkpoint = null		# The last checkpoint passed by the player.
# The path to the scene that the player character is held in.
var character_path = "res://Scenes/Player/character_sonic.tscn"

func _ready () -> void:
	print_debug ("Game-space ready.")
	helper_functions._whocares = $"Level_Timer".connect ("timeout", self, "update_level_timer")
	return

### update_hud
# Updates the in-game HUD (if it's there to update) by calling its hud_layer_update function.
# This is called mainly by the setters. It's also called by timer signals.
# ONLY this function should be used by any function that needs to update the HUD.
func update_hud () -> void:
	if (has_node ("/root/Level/hud_layer")):
		$"/root/Level/hud_layer".hud_layer_update ()
	return

### reset_game_space
# As singletons are not reset by restarting an application, they have to be handled manually.
func reset_game_space () -> void:
	level_time = Vector2.ZERO
	lives = DEFAULT_LIVES
	score = 0
	collectibles = 0
	collectibles_lives = 0
	player_character = null
	last_checkpoint = null
	return

### SETTERS AND GETTERS.
### Note: only setters update the HUD.

## For the lives.

# Should handle most death, dying and extra life notifications as required.
func set_lives (value:int) -> void:
	if (value > 99):				# Can only have 99 lives maximum...
		value = 99
	if (value > lives):				# Got an extra life!
		helper_functions._whocares = jingle_player.play_jingle ("res://Assets/Audio/Jingles/Extra_Life_PC.ogg")
	elif (value < lives):			# Lost a life.
		printerr ("TODO: Death!")
	else:
		printerr ("NOTE: Shouldn't see this! Trying to set the value of lives to what it already is.")
	lives = value
	update_hud ()
	return

func get_lives () -> int:
	return (lives)

## For the collectibles.

# Handles collecting items, and what to do when a certain number is reached if anything.
func set_collectibles (value:int) -> void:
	if (value > collectibles):
		# Collected something, so add what the difference is to the items-for-lives-counter.
		collectibles_lives += (value - collectibles)
	elif (value != collectibles):		# Lost items, so set the items-for-lives-counter to the new value.
		collectibles_lives = value
		sound_player.play_sound ("ring_loss")
	else:
		printerr ("NOTE: Shouldn't see this; attempting to change the value of collectibles to what it already is!")
	collectibles = value
	while (collectibles_lives >= DEFAULT_COLLECTIBLES_PER_LIFE):	# Collected enough for at least one extra life!
		game_space.lives += 1
		collectibles_lives -= DEFAULT_COLLECTIBLES_PER_LIFE
	update_hud ()
	return

func get_collectibles () -> int:
	return (collectibles)

## For score.

func set_score (value:int) -> void:
	score = value
	update_hud ()
	return

func get_score () -> int:
	return (score)

### TIMERS.

### update_level_timer
# Updates the current time in the level.
func update_level_timer () -> void:
	# Only update the timer if a cutscene is not playing.
	if (!(player_character.player_movement_state == player_character.MovementState.STATE_CUTSCENE)):
		level_time.y += 1			# Add one second to the timer.
		if (level_time.y > 59):		# Is it over a minute?
			level_time.y = 0		# If so, reset the seconds timer.
			level_time.x += 1		# And increase the minutes timer.
		update_hud ()
	return

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
   This controls the HUD part of the UI; that is, the stuff that is always on screen playing in-game. Keeps the HUD display
   updated. Updating every frame would be pretty heavy, so should be called only when something changes.
"""

extends CanvasLayer

var zero_collectibles = false	# For games that warn of no rings/collectibles.
var time_limit_near = false		# If you're getting near the time limit...

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("HUD ready on canvas layer ", layer, ".")
	hud_layer_update ()
	return

"""
   hud_layer_update

   Does all the heavy lifting. Updates the HUD (when called) to update all needed info. Should only ever be called when things
   actually change!
"""
func hud_layer_update ():
	var prettied_text = ""
	if (!has_node ("/root/Level")):	# Can't update the HUD for a level that doesn't exist!
		return						# Having this here avoids problems when running this scene on its own.
	## First things first, update the labels as needed.
	prettied_text = var2str (int (game_space.lives))			# Set up lives.
	$Lives_Count.text = prettied_text
	prettied_text = var2str (int (game_space.collectibles))	# Make sure items collected is correct.
	$Rings_Count.text = prettied_text
	prettied_text = var2str (int (game_space.score))			# Ditto the score.
	$Score_Count.text = prettied_text
	# Time is just a little more complicated, to make it look pretty.
	prettied_text = var2str (int (game_space.level_time.x))	# Show the minutes.
	prettied_text += ":"
	if (game_space.level_time.y < 10):	# If less than ten seconds, add a '0'.
		prettied_text += "0"
	prettied_text += var2str (int (game_space.level_time.y))	# Add the seconds.
	$Time_Count.text = prettied_text
	## Secondly, set animations to play if need be.
	if (game_space.collectibles <= 0):	# First up, items.
		if (!zero_collectibles):
			zero_collectibles = true
			$Rings_Symbol/AnimationPlayer.play ("warning")
	else:
		zero_collectibles = false
		$Rings_Symbol/AnimationPlayer.play ("default")
	if (game_space.level_time.x >= (game_space.DEFAULT_TIME_LIMIT - 1) && game_space.level_time.y > 49):
		if (!time_limit_near):
			time_limit_near = true
			$Time_Symbol/AnimationPlayer.play ("warning")
	else:
		time_limit_near = false
		$Time_Symbol/AnimationPlayer.play ("default")
	return

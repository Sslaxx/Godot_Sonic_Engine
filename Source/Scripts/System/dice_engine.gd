"""
   This file is part of:
   DICE ENGINE

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

extends Node

func _ready ():
	init_dice_engine ()	# Make sure the dice engine is ready.
	if (OS.is_debug_build ()):
		printerr (get_script ().resource_path, " ready.")
	return

"""
   roll_dice
   roll_dice (DiceNumber, DiceSides, AddTo, SubFrom)
   Rolls a given number (DiceNumber) of dice with sides (DiceSides).
   Can add to (AddTo) or subtract from (SubFrom) the calculated total.
   Defaults to 1d6+0-0 (1, 6, 0, 0).
   Returns the total given.
"""
func roll_dice (DiceNumber = 1, DiceSides = 6, AddTo = 0, SubFrom = 0):
	var Total = 0	# The total of the dice rolled.
	var Count = 0	# Used to count the number of dice rolled.
	var DiceRolled = 0	# Total of the dice rolled so far.
	for Count in range (0, DiceNumber):	# Roll the dice.
		DiceRolled = randi_range (1, DiceSides)
		Total = Total + DiceRolled
		printerr ("ROLLED: ", DiceRolled, " TOTAL IS NOW: ", Total)
	Total = (Total + AddTo) - SubFrom	# Total calculated, so do any addition or subtraction needed here.
	return (Total)	# And return it.

"""
   randi_range
   randi_range (Lower, Upper)
   Returns a random number from the range Lower to Upper. If for some reason it can't, it returns 0.
   Defaults to Lower = 1, Upper = 100. (1, 100)
"""
# FIXME: Remove if/when Godot proper implements this function!
func randi_range (Lower = 1, Upper = 100):
	if (Lower < Upper):
		return ((randi () % (1+Upper-Lower))+Lower)
	# If for some reason Upper is less than Lower (or the same value), print an error to the console and return 0.
	printerr ("ERROR: Upper cannot be less than (or equal to) Lower in randi_range; returning 0.")
	return (0)

"""
   init_dice_engine
   Just a front for the randomize function.
"""
func init_dice_engine ():
	randomize ()
	return (randi () % 16384576)	# 17664 workaround, ugh.

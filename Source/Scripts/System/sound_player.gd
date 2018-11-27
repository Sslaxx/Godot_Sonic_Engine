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
   For playing general sound effects (mostly UI, but other stuff too as required).
   Sound effects MUST be specified in Sound_Library along the lines of "<name>": preload ("<filename>").
   (Or <name> = preload ("<filename>"), your choice.) (Or "<name>": preload ("<filename>") etc etc.)
   Sound effects can be played using sound_player.play_sound ([<name>])

   Note it doesn't use 2D or 3D; it's best used for sounds that don't need to consider their positions.
"""

extends AudioStreamPlayer

onready var bus_index = AudioServer.get_bus_index ("SFX")

onready var Sound_Library = {
	# Put all the sound effects to be used globally here.
	No_Sound = preload ("res://Assets/Audio/Sound/No_Sound.ogg"),	# Keep this as the first item in the list.
}

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr (get_script ().resource_path, " ready.")
	return

"""
   play_sound
   play_sound (item)
   Looks for item in Sound_Library and if it's there, play it.
   Returns true if the item was found and the sound played, false otherwise.
"""
func play_sound (item = "No_Sound"):
	if (item in Sound_Library):
		# The sound exists in the library, so play it out and return true.
		stream = Sound_Library [item]
		play ()
		return (true)
	# Sound not found, so give an error and return false.
	printerr ("ERROR: \"", item, "\" not found!")
	return (false)

"""
   stop_sound
   Stops the sound player.
"""
func stop_sound ():
	stop ()
	return

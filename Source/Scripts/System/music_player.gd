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
   music_player - a singleton to be used to play music (normally looped, but whatever is necessary).
   For more advanced stuff (music that relies on signals and so on), do it in the scene directly.
"""

extends AudioStreamPlayer

onready var bus_index = AudioServer.get_bus_index ("Music")

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr (get_script ().resource_path, " ready.")
	return

"""
   play_music
   music_player.play_music (path_to_music, play_from)
   Plays a specified music file (path_to_music), unmuting the Music bus if need be.
   Will play from a specific point in the music (in seconds) if told to (play_from).
   Returns true if it plays something, otherwise false.
"""
## TODO: This could make use of typed GDScript in 3.1, in theory, as path_to_music is a string.
func play_music (path_to_music = "", play_from = 0.0):
	var play_me = null		# This will be used to set the stream data.
	if (!ResourceLoader.exists (path_to_music)):	# The file specified to play does not exist.
		printerr ("ERROR: ", path_to_music, " does not exist.")
		return (false)
	play_me = load (path_to_music)
	stream = play_me		# Everything's OK, so set the stream as needed?
	if (stream == null):	# Except it's not actually a music file, so error out.
		printerr ("ERROR: music_player has an empty stream! ", path_to_music, " is not a valid music file!")
		return (false)
	if (AudioServer.is_bus_mute (bus_index)):	# Unmute Music if it's muted...
		AudioServer.set_bus_mute (bus_index, false)
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Playing ", stream, " from ", path_to_music, ", offset ", play_from, ".")
	play (play_from)							# ...play the music...
	return (true)								# ...and return true.

"""
   stop_music
   music_player.stop_music ()
   Just a bit of syntactic sugar. Stops the currently playing music.
"""
func stop_music ():
	stop ()
	return

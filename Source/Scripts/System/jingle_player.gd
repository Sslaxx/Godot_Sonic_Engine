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
   jingle_player - a singleton to play music as a jingle.
   What this does is as follows:
   1 - Mutes the Music bus. This way any music will carry on playing, just silently.
   2 - plays the specified jingle.
   3 - at the end of the jingle, unmutes Music (if wanted; the default) so anything playing becomes audible again.

   It can either emit a "jingle_finished" signal (for having played the jingle in its entirety), or "jingle_aborted" (for a
   jingle having been stopped by something else).
"""

extends AudioStreamPlayer

onready var bus_index = AudioServer.get_bus_index ("Jingles")

signal jingle_finished	# Jingle played from start to finish.
signal jingle_aborted	# Jingle has been told to stop playing before it finished.

var unmute_music = true	# True (the default) will unmute the Music bus after playing the jingle; false will not.

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr (get_script ().resource_path, " ready.")
	self.connect ("finished", self, "stop_jingle")
	return

"""
   play_jingle
   jingle_player.play_jingle (path_to_jingle, music_unmute)
   Plays a specified music file as a jingle (path_to_jingle), muting the Music bus beforehand.
   After the jingle is finished, music_unmute can be set false to leave the music bus muted.
   Returns true if it plays something, otherwise false.
"""
## TODO: This could make use of typed GDScript, in theory, as path_to_jingle is a string.
func play_jingle (path_to_jingle = "", music_unmute = true):
	var play_me = null			# This will hold the stream for the jingle.
	var file = File.new ()		# Used to detect if a file exists or not.
	unmute_music = music_unmute	# Make sure music will be muted/unmuted after this jingle is done.
	if (!file.file_exists (path_to_jingle)):	# The file doesn't exist, so say so.
		printerr ("ERROR: ", path_to_jingle, " does not exist!")
		return (false)
	play_me = load (path_to_jingle)
	stream = play_me	# Set the stream.
	if (stream == null):	# If the stream is null, this means the sound file is invalid, so report an error.
		printerr ("ERROR: jingle_player has an empty stream! ", path_to_jingle, " is not a valid sound file.")
		return (false)
	AudioServer.set_bus_mute (music_player.bus_index, true)		# Mute the Music bus...
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Playing ", stream, " from ", path_to_jingle, ".")
	play ()														# ...play the jingle...
	return (true)												# ...and return true.

"""
   stop_jingle
   jingle_player.stop_jingle (abort_jingle)
   Stops the currently playing jingle and unmutes Music if told to.
   If abort_jingle is true, then it'll emit "jingle_aborted", otherwise "jingle_finished".
   You may need to unmute Music manually yourself in code if you leave it muted.
"""
func stop_jingle (abort_jingle = false):
	stop ()
	if (unmute_music):	# The default - unmute the music bus if this is true.
		AudioServer.set_bus_mute (music_player.bus_index, false)	# Note music_player unmutes Music if told to play something.
	unmute_music = true	# As this is a singleton, reset unmute_music after the check!
	if (abort_jingle):	# The jingle has been terminated early, so emit the "jingle_aborted" signal.
		emit_signal ("jingle_aborted")
	else:	# Jingle has played through.
		emit_signal ("jingle_finished")
	return

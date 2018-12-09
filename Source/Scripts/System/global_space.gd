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
   This script is set up to use global_space in the AutoLoad section of the project settings. This sets a global space for
   application-wide settings, flags, variables etc. which need to be easily passed around from scene/node to scene/node.

   For gameplay-related variables and functions, use game_space.tscn/gd.
"""

extends Node

# The following are used by go_to_scene.
onready var root = get_tree ().get_root ()
onready var current_scene = root.get_child (root.get_child_count () - 1)
onready var new_scene = null

# do_once_only uses this dictionary.
onready var do_once_dictionary = {
	NULL_DO_ONCE = "DO_NOT_DELETE",	# Keep me here!
}

func _ready ():
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY. Make it unavoidably obvious if debug mode is enabled.
		printerr ("Global script loaded.")
		OS.alert ("Debug mode is ENABLED", "DEBUG BUILD")
	Engine.target_fps = 60	# Make the game aim for 60fps (maximum).
	return

"""
   add_child_to_node
   global_space.add_child_to_node (Scene_Instance, Node_to_Add_to)
   Adds an (instanced!) scene (Scene_Instance) as a child to the given node (Node_to_Add_to).
   This neither creates an instance nor frees it, so you need to do those before/after calling this function respectively.
   It also does no error checking, so pass wrong things and/or in the wrong order and things will break.
"""
func add_child_to_node (Scene_Instance = null, Node_to_Add_to = "/root"):
	# Don't expect this to work properly (or at all) if you forget to create an *instance* of the scene to pass here!
	get_node (Node_to_Add_to).call_deferred ("add_child", Scene_Instance)
	return

"""
   add_path_to_node
   global_space.add_path_to_node (Scene_Path, Node_to_Add_to)
   Adds an instance of the scene specified by Scene_Path to the desired node (Node_to_Add_to).
   You should specify the path as absolute wherever possible.
   It doesn't do any error checking by and of itself, so do be careful!
   Returns the instance created.
"""
func add_path_to_node (Scene_Path = "", Node_to_Add_to = "/root"):
	var s = ResourceLoader.load (Scene_Path)	# Load and...
	s = s.instance ()							# ...create an instance of the scene specified by the path.
	add_child_to_node (s, Node_to_Add_to)		# Then add it to the specified node.
	return (s)									# Return the instance created.

"""
   go_to_scene
   global_space.go_to_scene (path)
   Goes to the relevant scene; the scene is a path, so "res://<filename>".
   You should specify the path as absolute wherever possible.
   Note that it deletes the previous scene!
   Returns the resultant scene node.
"""
func go_to_scene (path):
	var s = ResourceLoader.load (path)						# Load and...
	new_scene = s.instance ()								# ...create an instance of the scene to go to.
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		print ("Changing from ", current_scene, " to ", new_scene, ".")
	add_child_to_node (new_scene, get_tree ().get_root ().get_path ())	# Add the scene to the current root of the scene tree.
	get_tree ().set_current_scene (new_scene)				# Set the current scene being shown to the new scene...
	current_scene.queue_free ()								# ...delete the old scene from the tree...
	current_scene = new_scene								# ...and set the current_scene variable to be the new scene.
	return (current_scene)

"""
   do_once_only
   global_space.do_once_only (<string>)
   Does something once only (if the <string> given isn't in the dictionary for do_once_only). After that, it gets added so it
   won't do it again.
   Returns true first time round (because it hadn't been done before!), false afterwards.
   Try and avoid using this overly, but shouldn't make too much of an adverse impact on performance if used carefully.
"""
func do_once_only (do_me):
	if (OS.is_debug_build ()):	# FOR DEBUGGING ONLY.
		printerr ("Looking for ", do_me, ".")
	if (do_me in do_once_dictionary):	# Already been done once!
		return (false)					# Returns false as it has already been done before.
	# Not been done, so add it to the dictionary and return true.
	do_once_dictionary [do_me] = "I_AM_DONE"
	return (true)

### For playing general sound effects (mostly UI, but other stuff too as required).
# Sound effects MUST be specified in sound_library along the lines of "<name>": preload ("<filename>").
# (Or <name> = preload ("<filename>"), your choice.) (Or "<name>": preload ("<filename>") etc etc.)
# Sound effects can be played using sound_player.play_sound ([<name>])

extends AudioStreamPlayer

# If something needs to access the audio bus used by the player, it can be found here.
onready var bus_index := AudioServer.get_bus_index ("SFX")

onready var sound_library = {
	# Put all the sound effects to be used globally here. Using "add_sound_to_library" would be a better idea.
	no_sound = preload ("res://Assets/Audio/Sound/no_sound.ogg"),	# Keep this as the first item in the list.
}

func _ready () -> void:
	print_debug (get_script ().resource_path, " ready. Node ", self, " (", self.name, ").")
	return

### play_sound
# sound_player.play_sound (item)
# Looks for item in sound_library and if it's there, play it.
func play_sound (item = "no_sound") -> void:
	if (sound_library.has (item)):
		stream = sound_library [item] as AudioStream
		if (stream == null):	# The file associated with "item" isn't a valid sound file.
			printerr ("sound_player has an empty stream! ", item, " is not a valid sound file.")
			return
		# The sound exists and is valid in the library, so play it out.
		play ()
		print_debug (item, " played.")
		return
	# Sound not found, so give an error and return false.
	printerr ("ERROR: sound_player has no sound to play! \"", item, "\" not found!")
	return

### stop_sound
# Stops the sound player. Just syntactic sugar.
func stop_sound () -> void:
	stop ()
	return

### add_sound_to_library
# add_sound_to_library (sound_file, sound_name)
# Adds a sound resource to the library.
# Just give it a filename, the function will automatically load it with the name you give it.
func add_sound_to_library (sound_file, sound_name = "") -> void:
	if (sound_name == ""):			# If for some reason a name for the sound isn't supplied...
		sound_name = sound_file		# ...make it the same as the filename.
	if (sound_library.has (sound_name)):	# Can't add an entry that already exists.
		printerr ("add_sound_to_library can't add ", sound_name, "; it already exists in the library.")
		return
	sound_library [sound_name] = load (sound_file)
	print_debug ("Current sound_library contents: ", sound_library)
	return

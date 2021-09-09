extends AudioStreamPlayer2D

export(Array, AudioStream) var hurt

export(Array, AudioStream) var effort

func _ready():
	return

func play_hurt():
	stream = hurt[floor(hurt.size()*random_helpers.RNG.randf())]
	play(0)
	return

func play_effort():
	stream = effort[floor(effort.size()*random_helpers.RNG.randf())]
	play(0)
	return

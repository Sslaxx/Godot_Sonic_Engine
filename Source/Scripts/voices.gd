extends AudioStreamPlayer2D

export(Array, AudioStream) var hurt

export(Array, AudioStream) var effort

func _ready():
	randomize()

func play_hurt():
	stream = hurt[floor(hurt.size()*randf())]
	play(0)

func play_effort():
	stream = effort[floor(effort.size()*randf())]
	play(0)

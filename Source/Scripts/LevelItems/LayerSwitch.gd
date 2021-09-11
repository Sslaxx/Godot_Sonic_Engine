# flips sonic between the two available collision layers

extends Area2D

export(String, 'layer 0', 'layer 1', 'toggle') var function = 'layer 0'

func _tripped (area) -> void:
	if (area.name == 'Player'):
		if (function == 'layer 0'):
			area._layer0 (area)
		if (function == 'layer 1'):
			area._layer1 (area)
		if (function == 'toggle'):
			area._flipLayer (area)
	return

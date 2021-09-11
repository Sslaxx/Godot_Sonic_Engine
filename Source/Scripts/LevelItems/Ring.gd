# controls a typical (non-flying) ring

extends Area2D

# true if the ring has been collected 
var collected := false

# holds a reference to the AnimatedSprite node for the ring
onready var sprite = get_node ("AnimatedSprite")

# holds a referene to the AudioStreamPlayer for the ring
onready var audio = get_node ("AudioStreamPlayer")

var boostBar

# if the sprite has been collected, remove all visibility once the sparkle 
# animation finishes
func _process (_delta) -> void:
	if (collected and sprite.animation == "Sparkle" and sprite.frame >= 6):
		visible = false
	return

func _on_Ring_area_entered (area) -> void:
	# collide with the player, if the ring has not yet been collected
	if (not collected and area.name == "Player"):
		collected = true
		sprite.animation = "Sparkle"
		audio.play ()
		get_node ("/root/Node2D/CanvasLayer/RingCounter").addRing ()
		get_node ("/root/Node2D/CanvasLayer/boostBar").changeBy (2)
	return

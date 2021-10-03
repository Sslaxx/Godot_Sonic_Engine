# controls a typical (non-flying) ring

extends Area2D

# true if the ring has been collected 
var ring_collected := false

# holds a reference to the AnimatedSprite node for the ring
onready var ring_sprite = get_node ("AnimatedSprite")

var boostBar

# if the sprite has been collected, remove once the sparkle animation finishes
func _process (_delta) -> void:
	if (ring_collected and ring_sprite.animation == "Sparkle" and ring_sprite.frame >= 6):
		visible = false
		queue_free ()
	return

func _on_Ring_area_entered (area) -> void:
	# collide with the player, if the ring has not yet been collected
	if (not ring_collected and area.name == "Player"):
		ring_collected = true
		ring_sprite.animation = "Sparkle"
		sound_player.play_sound ("ring_get")
		game_space.rings_collected += 1
		game_space.change_boost_value (2)
	return

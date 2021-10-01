# this script is for the bouncy-type rings that fly out of you when you get hit

extends Area2D

# true if the ring has been collected 
var collected := false

# stores a reference to the raycast node
onready var downCast = get_node ("DownCast")
# holds a reference to the AnimatedSprite node for the ring
onready var sprite = get_node ("AnimatedSprite")
# holds a referene to the AudioStreamPlayer for the ring
onready var audio = get_node ("AudioStreamPlayer")

# holds a reference to the boost bar
#var boostBar

# timer variable to keep track of when the ring disappears.
var collectionStartTimer = 120

# represents the current velocity of the ring.
export(Vector2) var ring_velocity := Vector2.ZERO

func _process (_delta) -> void:
	# make the sprite invisible once the ring has been collected and
	# the sparkle animation is over
	if collected and sprite.animation == "Sparkle" and \
		sprite.frame >= 6:
		visible = false
	return

func _physics_process (_delta) -> void:
	# count down the timer
	collectionStartTimer -= 1

	if not collected:
		# bounce on relevent ground nodes
		if downCast.is_colliding () and downCast.get_collision_point ().y < position.y + 16:
			ring_velocity.y *= -1

		# add gravity
		ring_velocity.y += 0.02

		# apply velocity 
		position += ring_velocity

	# once the timer gets to a certain point, start flashing the ring sprite
	if collectionStartTimer < -900:
		sprite.modulate = Color (1,1,1,1- (-collectionStartTimer%30)/30.0)

	# remove the ring node once the timer is up
	if collectionStartTimer < -1080:
		queue_free ()
	return

func _on_Ring_area_entered (area) -> void:
	# if the ring hasn't been collected and the player collides...
	if not collected and area.name == "Player" and collectionStartTimer <= 0:
		collected = true					# set collected to true
		sprite.animation = "Sparkle"		# set the animation to the sparkle
		audio.play ()						# play the ring sfx
		get_node ("/root/Level/CanvasLayer/RingCounter").addRing ()	# add a ring to the total
	return

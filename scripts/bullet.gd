extends Area2D

@export var speed: float = 1300.0    # Pixels per second

func _physics_process(delta: float) -> void:
	# Move the bullet forward
	global_position += Vector2.UP.rotated(rotation) * speed * delta

	# Delete the bullet if it goes outside the screen
	if not get_viewport_rect().has_point(global_position):
		queue_free()

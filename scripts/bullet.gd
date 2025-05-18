extends Area2D

@export var speed: float = 1300.0    # Pixels per second

func _physics_process(delta: float) -> void:
	# Move the bullet forward
	global_position += Vector2.UP.rotated(rotation) * speed * delta

	# Delete the bullet if it goes outside the screen
	if not get_viewport_rect().has_point(global_position):
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("enemies"):
		body._on_area_2d_body_entered(self)   # Destroy the enemy
		queue_free()       # Destroy the bullet as well

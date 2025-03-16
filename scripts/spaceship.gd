extends CharacterBody2D

@export var acceleration: float = 900.0  # How fast the ship accelerates
@export var max_speed: float = 2000.0     # Max speed to prevent infinite acceleration
@export var rotation_speed: float = 3.0  # How fast the ship rotates
@export var damping: float = 0.98        # How much inertia slows down movement

const BASE_SCREEN_SIZE: Vector2 = Vector2(1920, 1080)  # Reference resolution
const BASE_SCALE: float = 2.0  # Default scale at 1920x1080

func _ready() -> void:
	velocity = Vector2.ZERO  # Initialize velocity

	# Get current screen size
	var screen_size = get_viewport_rect().size

	# Calculate scale factor based on reference resolution
	var scale_factor = min(screen_size.x / BASE_SCREEN_SIZE.x, screen_size.y / BASE_SCREEN_SIZE.y)
	
	# Apply scale to spaceship
	scale = Vector2.ONE * BASE_SCALE * scale_factor


func _process(delta: float) -> void:
	# Rotation handling (A = left, D = right)
	if Input.is_action_pressed("ui_left"): 
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("ui_right"): 
		rotation += rotation_speed * delta

	# Thrust handling (W = forward)
	if Input.is_action_pressed("ui_up"):
		var thrust = Vector2.UP.rotated(rotation) * acceleration * delta
		velocity += thrust

	# Limit max speed
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	# Apply damping (simulating friction in space)
	velocity *= damping

	# Move the spaceship
	position += velocity * delta

extends CharacterBody2D

@export var acceleration: float = 1100.0  
@export var max_speed: float = 2000.0    
@export var rotation_speed: float = 3.0  
@export var damping: float = 0.98        
@export var bounce_factor: float = 1.3   
@export var min_bounce_speed: float = 300.0  

const BASE_SCREEN_SIZE: Vector2 = Vector2(1920, 1080)  
const BASE_SCALE: float = 2.0  

@onready var engine_effect: AnimatedSprite2D = get_node("EngineEffect")

func _ready() -> void:
	velocity = Vector2.ZERO  

	var screen_size = get_viewport_rect().size
	var scale_factor = min(screen_size.x / BASE_SCREEN_SIZE.x, screen_size.y / BASE_SCREEN_SIZE.y)
	scale = Vector2.ONE * BASE_SCALE * scale_factor

	engine_effect.visible = false  

func _physics_process(delta: float) -> void:
	var is_thrusting = Input.is_action_pressed("ui_up")
	engine_effect.visible = is_thrusting
	
	if Input.is_action_pressed("ui_left"): 
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("ui_right"): 
		rotation += rotation_speed * delta

	if is_thrusting:
		var thrust = Vector2.UP.rotated(rotation) * acceleration * delta
		velocity += thrust

	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed

	velocity *= damping

	var collision = move_and_collide(velocity * delta)
	if collision:
		_handle_bounce(collision)

func _handle_bounce(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	var border_names = ["BorderUp", "BorderDown", "BorderLeft", "BorderRight"]

	if collider and collider.name in border_names:
		var normal = collision.get_normal()
		var new_velocity = velocity.bounce(normal) * bounce_factor

		if new_velocity.length() < min_bounce_speed:
			new_velocity = new_velocity.normalized() * min_bounce_speed
		
		velocity = new_velocity

extends CharacterBody2D

@export var max_lives: int = 3
var current_lives: int = max_lives

@export var acceleration: float = 1100.0
@export var max_speed:     float = 2000.0
@export var rotation_speed: float = 3.0
@export var damping:       float = 0.98
@export var bounce_factor: float = 1.3
@export var min_bounce_speed: float = 300.0

@export var heart_scene: PackedScene = preload("res://scenes/heart.tscn")
@onready var hearts_container := get_parent().get_node("HUD/HeartsContainer")
var hearts: Array = []

const BASE_SCREEN_SIZE: Vector2 = Vector2(1920, 1080)
const BASE_SCALE: float = 2.0

@onready var engine_effect: AnimatedSprite2D    = get_node("EngineEffect")
@onready var engine_sound:  AudioStreamPlayer2D = get_node("EngineSoundEffect")
@onready var shoot_sound: AudioStreamPlayer2D = get_node("ShootSoundEffect")

# -------------------------------------------------------------------------
# Shooting configuration  (hard-coded muzzle)
# -------------------------------------------------------------------------
@export var bullet_scene:    PackedScene = preload("res://scenes/bullet.tscn")
@export var fire_rate:       float = 0.15       # seconds between shots
@export var muzzle_distance: float = 50.0       # distance from ship origin to gun barrel
var _cooldown: float = 0.0                      # internal gun timer

func _ready() -> void:
	velocity = Vector2.ZERO

	# Create hearts based on max_lives
	for i in range(max_lives):
		var heart = heart_scene.instantiate()
		hearts_container.add_child(heart)
		hearts.append(heart)

	var screen_size = get_viewport_rect().size
	var scale_factor = min(screen_size.x / BASE_SCREEN_SIZE.x,
						   screen_size.y / BASE_SCREEN_SIZE.y)
	scale = Vector2.ONE * BASE_SCALE * scale_factor

	engine_effect.visible = false

func _physics_process(delta: float) -> void:
	var is_thrusting: bool = Input.is_action_pressed("ui_up")
	engine_effect.visible = is_thrusting

	# --- Audio ------------------------------------------------------------
	if is_thrusting:
		if not engine_sound.playing:
			engine_sound.play()
	else:
		if engine_sound.playing:
			engine_sound.stop()

	# --- Rotation ---------------------------------------------------------
	if Input.is_action_pressed("ui_left"):
		rotation -= rotation_speed * delta
	if Input.is_action_pressed("ui_right"):
		rotation += rotation_speed * delta

	# --- Thrust -----------------------------------------------------------
	if is_thrusting:
		velocity += Vector2.UP.rotated(rotation) * acceleration * delta

	# --- Shooting ---------------------------------------------------------
	_cooldown = max(_cooldown - delta, 0.0)
	if Input.is_action_just_pressed("shoot") and _cooldown == 0.0:
		_shoot()
		_cooldown = fire_rate

	# --- Speed clamp & damping -------------------------------------------
	if velocity.length() > max_speed:
		velocity = velocity.normalized() * max_speed
	velocity *= damping

	# --- Movement & bounce ------------------------------------------------
	var collision := move_and_collide(velocity * delta)
	if collision:
		_handle_bounce(collision)

# -------------------------------------------------------------------------
#  Helper functions
# -------------------------------------------------------------------------
func _shoot() -> void:
	var spawn_pos: Vector2 = global_position + Vector2.UP.rotated(rotation) * muzzle_distance

	var bullet := bullet_scene.instantiate() as Area2D
	bullet.global_position = spawn_pos
	bullet.rotation = rotation
	get_tree().current_scene.add_child(bullet)

	shoot_sound.play()

func take_damage(amount: int = 1) -> void:
	current_lives -= amount

	# Hide the heart if still in range
	if current_lives >= 0 and current_lives < hearts.size():
		hearts[current_lives].visible = false

	if current_lives <= 0:
		game_over()

func game_over() -> void:
	get_tree().current_scene.show_game_over()

func _handle_bounce(collision: KinematicCollision2D) -> void:
	var collider = collision.get_collider()
	var border_names = ["BorderUp", "BorderDown", "BorderLeft", "BorderRight"]

	if collider and collider.name in border_names:
		var new_velocity = velocity.bounce(collision.get_normal()) * bounce_factor

		if new_velocity.length() < min_bounce_speed:
			new_velocity = new_velocity.normalized() * min_bounce_speed

		velocity = new_velocity

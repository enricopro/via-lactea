extends Node2D

@export var enemy_scene: PackedScene = preload("res://scenes/sentinel.tscn")
@export var spawn_interval: float = 2.5
@export var spawn_margin: float = 100.0

var _spawn_timer: float = 5.0

func _physics_process(delta: float) -> void:
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		spawn_enemy()
		_spawn_timer = spawn_interval

func spawn_enemy() -> void:
	var enemy = enemy_scene.instantiate()
	get_tree().current_scene.add_child(enemy)

	var screen_rect = get_viewport().get_visible_rect()
	var spawn_position = get_random_position_around_screen(screen_rect, spawn_margin)
	enemy.global_position = spawn_position

func get_random_position_around_screen(screen_rect: Rect2, margin: float) -> Vector2:
	var side = randi() % 4
	match side:
		0: return Vector2(randf_range(screen_rect.position.x - margin, screen_rect.end.x + margin), screen_rect.position.y - margin)
		1: return Vector2(screen_rect.end.x + margin, randf_range(screen_rect.position.y - margin, screen_rect.end.y + margin))
		2: return Vector2(randf_range(screen_rect.position.x - margin, screen_rect.end.x + margin), screen_rect.end.y + margin)
		3: return Vector2(screen_rect.position.x - margin, randf_range(screen_rect.position.y - margin, screen_rect.end.y + margin))
	return Vector2.ZERO

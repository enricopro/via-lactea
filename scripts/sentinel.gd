extends CharacterBody2D  
 
@export var speed: float = 200.0  # Tweakable enemy speed
var player: Node2D = null

func _ready() -> void:
	# Find the player in the scene tree
	player = get_tree().current_scene.get_node("Spaceship")

func _physics_process(delta: float) -> void:
	if player:
		var direction = player.global_position - global_position
		rotation = direction.angle() + PI/2  # Rotate toward player
		global_position += direction.normalized() * speed * delta

func explode() -> void:
	speed = 0
	$Explosion/AudioStreamPlayer2D.play()
	$Explosion.visible = true
	$Explosion.play("default")
	$Sprite2D.visible = false
	$HitBox.set_deferred("disabled", true)
	$CollisionPolygon2D.set_deferred("disabled", true)
	$Explosion.animation_finished.connect(queue_free)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body == player || body.is_in_group("bullets"):
		explode()
	if body == player:
		body.take_damage()

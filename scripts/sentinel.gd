extends CharacterBody2D

@export var speed: float = 0.0  # Tweakable enemy speed
var player: Node2D = null

func _ready() -> void:
	# Find the player in the scene tree
	player = get_tree().current_scene.get_node("Spaceship")

func _physics_process(delta: float) -> void:
	if player:
		var direction = player.global_position - global_position
		rotation = direction.angle() + PI/2  # Rotate toward player
		global_position += direction.normalized() * speed * delta

func _on_body_entered(body: Node) -> void:
	if body == player:
		queue_free()  # Enemy disappears (you could trigger explosion here)
		#player_explode()  # Optional: implement in player later

# Connect this to the Area2D "body_entered" signal

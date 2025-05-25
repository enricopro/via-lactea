extends Node

@onready var game = $Game
@onready var start_screen = $Screens/StartScreen
@onready var game_over_screen = $Screens/GameOverScreen
@onready var hud = $Game/HUD
@onready var startscreen_soundtrack = $Screens/StartScreen/StartScreenSoundtrack

func _ready() -> void:
	show_start_screen()

func show_start_screen() -> void:
	game.visible = false
	hud.visible = false
	start_screen.visible = true
	game_over_screen.visible = false
	get_tree().paused = true

func start_game() -> void:
	var tween = create_tween()
	tween.tween_property(startscreen_soundtrack, "volume_db", -40, 0.3)
	tween.finished.connect(startscreen_soundtrack.stop)
	game.visible = true
	hud.visible = true
	start_screen.visible = false
	game_over_screen.visible = false
	get_tree().paused = false

func show_game_over() -> void:
	game.visible = false
	hud.visible = false
	start_screen.visible = false
	game_over_screen.visible = true
	get_tree().paused = true

func retry_game() -> void:
	get_tree().reload_current_scene()

func _on_play_button_pressed() -> void:
	start_game()

func _on_retry_button_pressed() -> void:
	retry_game()

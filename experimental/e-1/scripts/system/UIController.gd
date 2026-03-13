extends Node
class_name UIController

@export var hud: UIHUD
@export var gameview: UIGameView
@export var screen: UIScreen

@export var time: TimeManager

func _ready() -> void:
	GameState.game_state_changed.connect(_on_game_state_changed)
	
func _on_game_state_changed(status: GameState.Status) -> void:
	match status:
		GameState.Status.LOADING:
			show_loading_screen()
		GameState.Status.PLAYING:
			set_all_invisible()
			show_game()
			show_hud()

func set_all_invisible() -> void:
	hud.visible = false
	gameview.visible = false
	screen.visible = false
	
func show_black() -> void:
	set_all_invisible()
	screen.visible = true
	screen.bg_color.color = Color(0, 0, 0, 1)

func show_loading_screen() -> void:
	show_black()
	screen.central_message.text = "Loading..."

func show_game() -> void:
	gameview.visible = true
	
func show_hud() -> void:
	hud.visible = true

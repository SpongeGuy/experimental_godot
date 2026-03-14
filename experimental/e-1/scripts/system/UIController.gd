extends Node
class_name UIController

@export var hud: UIHUD
@export var gameview: UIGameView
@export var screen: UIScreen

func _ready() -> void:
	GameState.game_state_changed.connect(_on_game_state_changed)
	EventBus.day_state_changed.connect(_on_day_state_changed)
	
func _process(delta: float) -> void:
	if GameState.state != GameState.Status.PLAYING:
		return
	_update_hud()
	
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


func _update_hud() -> void:
	var day_length: float = TimeManager.DAYTIMES[TimeManager.DAYTIMES.size() - 1]
	if day_length - TimeManager.elapsed >= 0:
		hud.time_label.text = str( "%02d:%02d" % [int((day_length - TimeManager.elapsed) / 60), int(day_length - TimeManager.elapsed) % 60])
	

func _on_day_state_changed(state: TimeManager.DayState, name: String) -> void:
	hud.time_message_label.text = str(name)

extends Node

@export var time: TimeManager
@export var camera: CameraController
@export var weather: WeatherComponent
@export var anthurium: AnthuriumManager
@export var dungeon_generator: DungeonGenerator
@export var player: PlayerManager

func _ready() -> void:
	call_deferred("initialize_game")
	
	

	

func _physics_process(delta: float) -> void:
	if GameState.state == GameState.Status.PLAYING:
		time.elapsing = true
		camera.go_to(player.player.global_position, delta)
		handle_weather(delta)
		
func handle_weather(delta: float) -> void:
	if time.day_state == TimeManager.DayState.DAWN:
		weather.set_fog_pulse_params(25, 30, 1)
		weather.fog_pulse(delta)
		weather.move_fog_to(anthurium.anthurium.global_position, delta)
		weather.change_weather_tint_to(delta, Color(0.766, 0.229, 0.621, 1.0))
		weather.change_fog_color_to(delta, Color(0.035, 0.028, 0.097, 1.0))
	else:
		weather.set_fog_pulse_params(100, 130, 1)
		weather.fog_pulse(delta)
		weather.move_fog_to(anthurium.anthurium.global_position, delta)
		weather.change_weather_tint_to(delta, Color(0.822, 0.784, 0.967, 1.0))
		weather.change_fog_color_to(delta, Color(0.443, 0.446, 0.653, 1.0))

func initialize_game() -> void:
	GameState.change_game_state(GameState.Status.LOADING)
	
	WorldGrid.init_grid(64, 64)
	call_deferred("_start_generation")
	call_deferred("_spawn_heroes")
	
	await get_tree().create_timer(1).timeout
	GameState.change_game_state(GameState.Status.PLAYING)

func _start_generation() -> void:
	dungeon_generator.generate()
	
	var cell = CellData.new()
	cell.terrain = CellData.TerrainType.GROUND
	WorldGrid.set_rectangle(Vector2(16,16), Vector2(16, 16), cell)

func _spawn_heroes() -> void:
	player.initialize_player_at(Vector2(490, 540))
	anthurium.initialize_anthurium_at(Vector2(512, 512))

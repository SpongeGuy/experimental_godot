extends Node

# initialization
signal starting_new_game()
signal camera_ready(camera: Camera2D)
signal weather_ready(weather: WeatherComponent)
signal ysort_ready(ysort: Node2D)
signal ready_to_generate_terrain()
signal terrain_generated_successfully()
signal ready_to_spawn_player(position: Vector2)
signal ready_to_spawn_anthurium(position: Vector2)

# entity lifecycle
signal entity_spawned(entity: Node2D)
signal player_spawned(player: Node2D)
signal player_died()
signal spawn_requested()

# anthurium
signal anthurium_spawned(entity: Node2D)
signal anthurium_died()

# time
signal day_state_changed(state: TimeManager.DayState, name: String)

# camera
signal change_camera_target(target: Node2D)

# fog
signal change_fog_target(target: Node2D)
signal change_fog_pulse_params(min: float, max: float, rate: float)

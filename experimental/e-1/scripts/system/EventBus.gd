extends Node

# initialization
signal starting_new_game()
signal camera_ready(camera: Camera2D)
signal weather_ready(weather: WeatherComponent)
signal ysort_ready(ysort: Node2D)
signal terrain_generated_successfully()

# entity lifecycle
signal spawn_requested(entity_type: StringName, pos: Vector2)
signal entity_spawned(entity: Node2D)
signal player_spawned(player: Node2D)
signal player_died()
signal entity_killed(entity: Node2D)
signal entity_destroyed(entity: Node2D)

# anthurium
signal anthurium_spawned(entity: Node2D)
signal anthurium_died()

# time
signal day_state_changed(state: TimeManager.DayState, name: String)

# camera
signal camera_target_changed(target: Node2D)

# fog
signal fog_target_changed(target: Node2D)
signal change_fog_pulse_params(min: float, max: float, rate: float)

# inventories
signal item_put_into_inventory(item: Entity)

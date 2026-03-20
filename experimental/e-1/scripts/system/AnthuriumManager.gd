extends Node
class_name AnthuriumManager

static var anthurium: Entity


func spawn_anthurium(pos: Vector2) -> void:
	anthurium = EntityManager.spawn_safely(&"anthurium", pos)
	EventBus.anthurium_spawned.emit(anthurium)
	WeatherController.change_fog_target(anthurium)
	GameState.anthurium = anthurium

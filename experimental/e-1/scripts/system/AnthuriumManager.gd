extends Node
class_name AnthuriumManager

static var anthurium: Entity


func spawn_anthurium(pos: Vector2) -> void:
	anthurium = EntityManager.spawn_safely(&"anthurium", pos)
	#call_deferred("_set_circle_at_position", pos)
	EventBus.anthurium_spawned.emit(anthurium)
	WeatherController.change_fog_target(anthurium)


func _set_circle_at_position(pos: Vector2) -> void:
	var cell: CellData = CellData.new()
	cell.terrain = CellData.TerrainType.GROUND
	WorldGrid.set_circle(WorldGrid.world_to_tile(pos), 6, cell)

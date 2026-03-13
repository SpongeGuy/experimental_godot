extends Node
class_name AnthuriumManager

var anthurium: Entity
var anthurium_scene: PackedScene = preload("res://scenes/plants/anthurium.tscn")


func initialize_anthurium_at(pos: Vector2) -> void:
	var a = anthurium_scene.instantiate()
	a.global_position = pos
	EntityManager.add_entity(a)
	call_deferred("_set_circle_at_position", pos)
	anthurium = a
	EventBus.anthurium_spawned.emit(a)

func _set_circle_at_position(pos: Vector2) -> void:
	var cell: CellData = CellData.new()
	cell.terrain = CellData.TerrainType.GROUND
	WorldGrid.set_circle(WorldGrid.world_to_tile(pos), 6, cell)

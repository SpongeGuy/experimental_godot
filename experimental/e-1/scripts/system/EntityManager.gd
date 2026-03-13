extends Node
class_name EntityManager

@export var ysort: Node2D
static var _entity_container: Node2D

func _ready() -> void:
	if ysort:
		_entity_container = ysort

static func get_entity_container():
	if _entity_container:
		return _entity_container
	return null

static func add_entity(e: Entity) -> void:
	_entity_container.add_child(e)
	EventBus.entity_spawned.emit(e)

static func summon_entity_in_safe_location(pos: Vector2, entity: Entity) -> void:
	var start: Vector2i = WorldGrid.world_to_tile(pos)
	
	for radius in range(0, 64):
		for coords in WorldGrid.get_coords_in_radius(start, radius):
			var cell = WorldGrid.get_cell(coords)
			if cell and cell.terrain == CellData.TerrainType.GROUND:
				entity.global_position = WorldGrid.tile_to_world(coords)
				add_entity(entity)

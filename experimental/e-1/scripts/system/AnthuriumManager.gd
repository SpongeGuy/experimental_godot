extends Node
class_name AnthuriumManager

static var anthurium: Entity

func _ready() -> void:
	EventBus.ready_to_spawn_anthurium.connect(_spawn_anthurium)

func _spawn_anthurium(pos: Vector2) -> void:
	initialize_anthurium_at(pos)
	EventBus.change_fog_target.emit(anthurium)

func initialize_anthurium_at(pos: Vector2) -> void:
	anthurium = EntityManager.spawn_safely(&"anthurium", pos)
	call_deferred("_set_circle_at_position", pos)
	
	EventBus.anthurium_spawned.emit(anthurium)

func _set_circle_at_position(pos: Vector2) -> void:
	var cell: CellData = CellData.new()
	cell.terrain = CellData.TerrainType.GROUND
	WorldGrid.set_circle(WorldGrid.world_to_tile(pos), 6, cell)

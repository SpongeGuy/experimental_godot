extends Component
class_name WorldInterface

var current_cell: CellData = null
var current_cell_position: Vector2

func _physics_process(delta: float) -> void:
	current_cell = _sample_cell(entity)
	current_cell_position = floor(entity.global_position / WorldGrid.tile_size) * WorldGrid.tile_size

func _sample_cell(body: CharacterBody2D) -> CellData:
	if not WorldGrid:
		return null
		
	var coords = Vector2i(body.global_position / WorldGrid.tile_size)
	return WorldGrid.get_cell(coords)


func cell_movement_modifier() -> float:
	if current_cell == null or current_cell.terrain != CellData.TerrainType.GROUND:
		return 1.0
	return current_cell.movement_multiplier
	
func cell_friction_multiplier() -> float:
	if current_cell == null or current_cell.terrain != CellData.TerrainType.GROUND:
		return 1.0
	return current_cell.friction
	


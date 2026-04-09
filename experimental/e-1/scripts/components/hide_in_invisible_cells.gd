extends Component
class_name HideInInvisibleCells

# -----------------------------------------------------------
# works automatically to interface with the WorldGrid to set
# the entity to be visible or not based on if the tile it is standing on is visibles
# ---------------------------------------------------------v

@export var visibility: VisibilityComponent

func _ready() -> void:
	WorldGrid.cell_hidden.connect(_on_cell_hidden)
	WorldGrid.cell_revealed.connect(_on_cell_revealed)
	WorldGrid.cells_visibled.connect(_on_cells_visibled)

func _on_cells_visibled(batch: Dictionary[Vector2i, bool]) -> void:
	var inside: bool = false
	var cell: CellData
	for coords in batch.keys():
		if WorldGrid.world_to_tile(entity.global_position) == coords:
			cell = WorldGrid.get_cell(coords)
			inside = true
			break
	if not inside:
		return
	
	resolve_visibility(cell)
	
func _on_cell_hidden(coords: Vector2i) -> void:
	if WorldGrid.world_to_tile(entity.global_position) != coords:
		return
		
	var cell: CellData = WorldGrid.get_cell(coords)
	resolve_visibility(cell)
	
	
func _on_cell_revealed(coords: Vector2i) -> void:
	if WorldGrid.world_to_tile(entity.global_position) != coords:
		return
		
	var cell: CellData = WorldGrid.get_cell(coords)
	resolve_visibility(cell)


func resolve_visibility(cell: CellData) -> void:
	if cell.invisible and visibility._visible == true:
		visibility.set_visibility(false)
	
	if not cell.invisible and visibility._visible == false:
		visibility.set_visibility(true)

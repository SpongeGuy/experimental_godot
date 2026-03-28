extends TileMapLayer
class_name WorldRenderer



const ATLAS_SOURCE_ID = 0

func _ready() -> void:
	WorldGrid.cell_changed.connect(_on_cell_changed)
	WorldGrid.cells_changed.connect(_on_cells_changed)
	
func _on_cell_changed(coords: Vector2i, cell: CellData) -> void:
	_draw_cell(coords, cell)
	
func _on_cells_changed(batch: Dictionary[Vector2i, CellData]) -> void:
	for coordinate in batch:
		_draw_cell(coordinate, batch[coordinate])
	
func _draw_cell(coords: Vector2i, cell: CellData) -> void:
	cell.resolve_atlas_coordinate()
	set_cell(coords, ATLAS_SOURCE_ID, cell.atlas_coordinate)
	
func render_all() -> void:
	for y in WorldGrid.height:
		for x in WorldGrid.width:
			var coords = Vector2i(x, y)
			var cell: CellData = WorldGrid.get_cell(coords)
			_draw_cell(coords, cell)
			


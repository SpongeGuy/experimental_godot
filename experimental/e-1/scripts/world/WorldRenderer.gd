extends TileMapLayer
class_name WorldRenderer

const TERRAIN_ATLAS: Dictionary = {
	CellData.TerrainType.GROUND: Vector2i(0, 0),
	CellData.TerrainType.WALL: Vector2i(1, 0),
	CellData.TerrainType.GAP: Vector2i(2, 0),
}

const ATLAS_SOURCE_ID = 0

func _ready() -> void:
	WorldGrid.cell_changed.connect(_on_cell_changed)
	
func render_all() -> void:
	for y in WorldGrid.height:
		for x in WorldGrid.width:
			var coords = Vector2i(x, y)
			_draw_cell(coords)
			
func _on_cell_changed(coords: Vector2i) -> void:
	_draw_cell(coords)
	
func _draw_cell(coords: Vector2i) -> void:
	var cell = WorldGrid.get_cell(coords)
	if not cell:
		return
		
	var atlas_coords = TERRAIN_ATLAS.get(cell.terrain, Vector2i(0, 0))
	set_cell(coords, ATLAS_SOURCE_ID, atlas_coords)

extends TileMapLayer
class_name WorldRenderer



const ATLAS_SOURCE_ID = 0

func _ready() -> void:
	WorldGrid.cell_changed.connect(_on_cell_changed)
	
func _on_cell_changed(coords: Vector2i) -> void:
	_draw_cell(coords)
	
func _draw_cell(coords: Vector2i) -> void:
	var cell = WorldGrid.get_cell(coords)
	if not cell:
		return
		
	cell.resolve_atlas_coordinate()
	set_cell(coords, ATLAS_SOURCE_ID, cell.atlas_coordinate)
	
func render_all() -> void:
	for y in WorldGrid.height:
		for x in WorldGrid.width:
			var coords = Vector2i(x, y)
			_draw_cell(coords)
			


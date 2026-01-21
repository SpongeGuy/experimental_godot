class_name Chunk
extends RefCounted

const CHUNK_SIZE = 8

var cells: Array = []
var chunk_pos: Vector2i

func _init(pos: Vector2i) -> void:
	chunk_pos = pos
	
	cells.resize(CHUNK_SIZE * CHUNK_SIZE) # resizing array and then assigning values is faster than appending
	for i in range(CHUNK_SIZE * CHUNK_SIZE):
		cells[i] = Cell.create_empty()

func get_cell(local_x: int, local_y: int) -> Cell:
	# get cell using local chunk coordinates with (0, 0) being the origin
	if local_x < 0 or local_x >= CHUNK_SIZE or local_y < 0 or local_y >= CHUNK_SIZE:
		push_warning("Get cell local coordinate out of bounds! returning null")
		return null
	return cells[local_y * CHUNK_SIZE + local_x]
	
func set_cell(local_x: int, local_y: int, cell: Cell):
	# set cell using local coordinates with (0, 0) being the origin
	if local_x < 0 or local_x >= CHUNK_SIZE or local_y < 0 or local_y >= CHUNK_SIZE:
		push_warning("Set cell local coordinate out of bounds! returning null")
		return null
	cells[local_y * CHUNK_SIZE + local_x] = cell
	
var debug_switch: bool = false	
func process(delta: float):
	# update all cells in this chunk
	for cell in cells:
		if cell:
			cell.process(delta)
	if not debug_switch:
		for cell in cells:
			try_spawn_plant()
			try_spawn_plant()
			try_spawn_plant()
			try_spawn_plant()
			try_spawn_plant()
			try_spawn_plant()
			try_spawn_plant()
		debug_switch = true

func get_all_cells_of_type(type: Cell.Type) -> Array[Cell]:
	# get all cells matching a type
	var result: Array[Cell] = []
	for cell in cells:
		if cell and cell.cell_type == type:
			result.append(cell)
	return result
	
func count_cells_of_type(type: Cell.Type) -> Array[Cell]:
	var count = 0
	for cell in cells:
		if cell and cell.type == type:
			count += 1
	return count

# HELPER FUNCTIONS #------------------------------

var plant = preload("res://debug_plant.tscn")

func try_spawn_plant() -> void:
	var random_x: int = randi_range(0, CHUNK_SIZE - 1)
	var random_y: int = randi_range(0, CHUNK_SIZE - 1)
	var cell: Cell = get_cell(random_x, random_y)
	if cell.type == Cell.Type.GROUND:
		var p = plant.instantiate()
		var random_offset: Vector2 = Vector2(randi_range(0, Cell.CELL_SIZE - 1), randi_range(0, Cell.CELL_SIZE - 1))
		p.position = WorldManager.chunk_to_world(chunk_pos, Vector2i(random_x, random_y)) + random_offset
		EntityManager.add_entity_to_world(p)
		

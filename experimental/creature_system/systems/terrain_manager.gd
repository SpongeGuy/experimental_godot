extends Node2D

@onready var tile_map_base: TileMapLayer = $Terrain
@onready var flower_path = preload("res://nodes/entity/items/flower.tscn")

var visited_cells: Array[Vector2i] = []


func _ready() -> void:
	var area: Rect2i = Rect2i(0, 0, 50, 50)
	var terrain_set: int = 0
	var terrain: int = 0
	var steps: int = 300
	fill_rectangle(area, tile_map_base, terrain_set, terrain)
	drunk(Vector2i(0, 0), tile_map_base, terrain_set, 0, 1, steps, 0.01)

func fill_rectangle(area: Rect2i, tile_map_layer: TileMapLayer, terrain_set: int, terrain: int) -> void:
	var cells: Array[Vector2i] = []
	for x in range(area.position.x, area.end.x):
		for y in range(area.position.y, area.end.y):
			cells.append(Vector2i(x, y))
	tile_map_layer.set_cells_terrain_connect(cells, terrain_set, terrain)
	
const DIRECTIONS: Array[Vector2i] = [
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, 0),
	Vector2i(1, 0)
]

# initiates drunkards walks until remaining steps is 0
# picks a spot which the drunkard has already traversed and walks out from there
func drunk(start_pos: Vector2i, tile_map_layer: TileMapLayer, terrain_set: int, from_terrain: int, to_terrain: int, remaining_steps: int, delay: float):
	var starting_position = start_pos
	while remaining_steps > 0:
		remaining_steps -= await drunkards_walk(starting_position, tile_map_layer, terrain_set, from_terrain, to_terrain, remaining_steps, delay)
		var random_pos = visited_cells.pick_random()
		starting_position = random_pos
	visited_cells = []

func drunkards_walk(start_pos: Vector2i, tile_map_layer: TileMapLayer, terrain_set: int, from_terrain: int, to_terrain: int, max_steps: int, delay: float) -> int:
	var current_pos: Vector2i = start_pos
	var cells_to_connect: Array[Vector2i] = [current_pos]
	
	tile_map_layer.set_cells_terrain_connect([current_pos], terrain_set, to_terrain)
	if delay > 0:
		await get_tree().create_timer(delay).timeout
		
	var steps_taken: int = 0
	while steps_taken < max_steps:
		# walking
		visited_cells.append(current_pos)
		var valid_moves: Array[Vector2i] = []
		for dir in DIRECTIONS:
			var next_pos: Vector2i = current_pos + dir
			# check if next cells is the from_terrain
			if tile_map_layer.get_cell_tile_data(next_pos) != null and tile_map_layer.get_cell_tile_data(next_pos).terrain == from_terrain:
				valid_moves.append(next_pos)
				
		if valid_moves.is_empty():
			break # stuck, end walk
		
		var next_pos: Vector2i = valid_moves.pick_random()
		current_pos = next_pos
		
		if to_terrain == 1:
			var flower = flower_path.instantiate()
			var tile_size = tile_map_layer.tile_set.tile_size.x
			flower.position = tile_size * next_pos + Vector2i(tile_size / 2, tile_size / 2)
			get_parent().add_child(flower)
			var new_area: Rect2 = Rect2(next_pos * tile_size, Vector2(tile_size, tile_size))
			#print(get_nodes_in_rect_physics(new_area, 2))

		if to_terrain == 0:
			var tile_size = tile_map_layer.tile_set.tile_size.x
		
		if delay > 0:
			tile_map_layer.set_cells_terrain_connect([current_pos], terrain_set, to_terrain)
			await get_tree().create_timer(delay).timeout
		else:
			cells_to_connect.append(current_pos)
		steps_taken += 1
		
		if delay <= 0:
			tile_map_layer.set_cells_terrain_connect(cells_to_connect, terrain_set, to_terrain)
	return steps_taken
			
# gets all nodes within a specified rectangle and on a specified collision layer
func get_nodes_in_rect_physics(rect: Rect2, collision_layer: int = 1, max_results: int = 32) -> Array[Node]:
	var space_state: PhysicsDirectSpaceState2D = get_world_2d().direct_space_state
	var shape: RectangleShape2D = RectangleShape2D.new()
	shape.size = rect.size
	
	var params: PhysicsShapeQueryParameters2D = PhysicsShapeQueryParameters2D.new()
	params.shape = shape
	params.transform = Transform2D(0, rect.position + rect.size / 2)
	params.collision_mask = collision_layer
	params.collide_with_bodies = true
	params.collide_with_areas
	
	var results: Array[Dictionary] = space_state.intersect_shape(params, max_results)
	var nodes: Array[Node] = []
	for hit in results:
		if hit.collider is Node:
			nodes.append(hit.collider)
	return nodes

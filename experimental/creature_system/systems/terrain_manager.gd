class_name TerrainManager extends Node2D

var tile_health: Dictionary = {}
@export var default_health: float = 5
@export var terrain_set_id: int = 0
@export var wall_terrain_id: int = 0
@export var ground_terrain_id: int = 1

@onready var walls_layer: TileMapLayer = $Walls
@onready var ground_layer: TileMapLayer = $Ground

var flower_scene = preload("res://nodes/entity/items/flower.tscn")
var thud_sound: AudioStream = preload("res://assets/sounds/thud_2.wav")
var break_sound: AudioStream = preload("res://assets/sounds/break_1.wav")

# batch collection for removals (cleared each frame)
var removed_tiles: Array[Vector2i] = []

var flower_container: Node = Node.new()

var map_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(360, 360))

func _ready() -> void:
	add_to_group("world")
	get_parent().add_child.call_deferred(flower_container)
	call_deferred("update_navigation_map")
	print("TileSet assigned: ", walls_layer.tile_set != null)
	
	initialize_tile_health()
	initialize_ground_layer()
	spawn_flowers()
	
func initialize_tile_health() -> void:
	var used_cells = get_used_cells(walls_layer)
	for cell in used_cells:
		tile_health[cell] = default_health
		
func initialize_ground_layer() -> void:
	var tile_size = walls_layer.tile_set.tile_size
	var min_tile = global_to_tile_pos(map_bounds.position)
	var max_tile = global_to_tile_pos(map_bounds.end)
	var ground_tiles: Array[Vector2i] = []
	for x in range(min_tile.x, max_tile.x + 1):
		for y in range(min_tile.y, max_tile.y + 1):
			var tile_pos = Vector2i(x, y)
			if get_cell_source_id(walls_layer, tile_pos) == -1:
				print(tile_pos_to_global(tile_pos))
				ground_tiles.append(tile_pos)
	
	set_terrain_cells(ground_layer, ground_tiles, ground_terrain_id)

func damage_tile(tile_pos: Vector2i, damage: float) -> void:
	var random_pitch = randf_range(0.7, 1.3)
	if tile_health.has(tile_pos):
		tile_health[tile_pos] -= damage
		AudioManager.play_sound(thud_sound, map_to_local(walls_layer, tile_pos), {"pitch_scale": random_pitch})
		print(tile_health[tile_pos])
		if tile_health[tile_pos] <= 0:
			destroy_wall(tile_pos)
			AudioManager.play_sound(break_sound, map_to_local(walls_layer, tile_pos), {"pitch_scale": random_pitch})

func create_wall(tile_pos: Vector2i) -> void:
	# Step 1: Check if there's a ground tile present. If so, delete it
	if get_cell_source_id(ground_layer, tile_pos) != -1:
		set_terrain_cells(ground_layer, [tile_pos], -1)
		# Change adjacent ground tiles appearance based on autotiling logic
		update_terrain_neighbors(ground_layer, tile_pos, ground_terrain_id)

	# Step 2: Place the wall tile
	set_terrain_cells(walls_layer, [tile_pos], wall_terrain_id)
	tile_health[tile_pos] = default_health

	# Step 3: Change the placed wall and adjacent walls based on autotiling logic
	update_terrain_neighbors(walls_layer, tile_pos, wall_terrain_id)
	update_navigation_map()

func destroy_wall(tile_pos: Vector2i) -> void:
	# Step 1: Check if there's a wall tile present. If so, delete it
	if get_cell_source_id(walls_layer, tile_pos) != -1:
		set_terrain_cells(walls_layer, [tile_pos], -1)
		tile_health.erase(tile_pos)

		# Step 2: Change adjacent walls appearance based on autotiling logic
		update_terrain_neighbors(walls_layer, tile_pos, wall_terrain_id)

		# Step 3: Place a ground tile where the wall used to be
		set_terrain_cells(ground_layer, [tile_pos], ground_terrain_id)

		# Step 4: Change adjacent ground tiles appearance based on autotiling logic
		update_terrain_neighbors(ground_layer, tile_pos, ground_terrain_id)
	
	update_navigation_map()

# Standalone: Get used cells on a layer
func get_used_cells(layer: TileMapLayer) -> Array[Vector2i]:
	return layer.get_used_cells()

# Standalone: Get neighbors
func get_neighbors(tile_pos: Vector2i) -> Array[Vector2i]:
	return [
		Vector2i(tile_pos.x - 1, tile_pos.y - 1), Vector2i(tile_pos.x, tile_pos.y - 1), Vector2i(tile_pos.x + 1, tile_pos.y - 1),
		Vector2i(tile_pos.x - 1, tile_pos.y), Vector2i(tile_pos.x + 1, tile_pos.y),
		Vector2i(tile_pos.x - 1, tile_pos.y + 1), Vector2i(tile_pos.x, tile_pos.y + 1), Vector2i(tile_pos.x + 1, tile_pos.y + 1)
	]

# Standalone: Get cell source ID on a layer
func get_cell_source_id(layer: TileMapLayer, tile_pos: Vector2i) -> int:
	return layer.get_cell_source_id(tile_pos)

# Standalone: Map to local on a layer
func map_to_local(layer: TileMapLayer, tile_pos: Vector2i) -> Vector2:
	return layer.map_to_local(tile_pos)

# Standalone: Set terrain cells with autotiling on a layer
func set_terrain_cells(layer: TileMapLayer, cells: Array[Vector2i], terrain_id: int) -> void:
	if cells.size() > 0:
		layer.set_cells_terrain_connect(cells, terrain_set_id, terrain_id)
		layer.force_update_transform()

# Standalone: Update terrain neighbors with autotiling on a layer
func update_terrain_neighbors(layer: TileMapLayer, tile_pos: Vector2i, terrain_id: int) -> void:
	var neighbors = get_neighbors(tile_pos)
	var valid_neighbors: Array[Vector2i] = []
	for neighbor in neighbors:
		if get_cell_source_id(layer, neighbor) != -1:
			valid_neighbors.append(neighbor)
	set_terrain_cells(layer, valid_neighbors, terrain_id)

func spawn_flowers() -> void:
	var tile_size = walls_layer.tile_set.tile_size
	var min_tile = global_to_tile_pos(map_bounds.position)
	var max_tile = global_to_tile_pos(map_bounds.end)
	var empty_count = 0
	for x in range(min_tile.x, max_tile.x + 1):
		for y in range(min_tile.y, max_tile.y + 1):
			var tile_pos = Vector2i(x, y)
			if get_cell_source_id(walls_layer, tile_pos) == -1 and get_cell_source_id(ground_layer, tile_pos) != -1:
				spawn_flower_at(tile_pos)
				empty_count += 1
	print("Spawned ", empty_count, " flowers on ground layer")

func spawn_flower_at(tile_pos: Vector2i) -> void:
	if flower_scene:
		var global_pos = tile_pos_to_global(tile_pos)
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsPointQueryParameters2D.new()
		query.position = global_pos
		query.collision_mask = 2
		var collisions = space_state.intersect_point(query)
		if collisions.is_empty():
			var flower = flower_scene.instantiate() as Item
			flower.global_position = global_pos
			flower_container.add_child.call_deferred(flower)
			flower.is_carryable = false

func tile_pos_to_global(tile_pos: Vector2i) -> Vector2:
	var local_pos = walls_layer.map_to_local(tile_pos)
	return walls_layer.to_global(local_pos)

func global_to_tile_pos(global_pos: Vector2) -> Vector2i:
	var local_pos = walls_layer.to_local(global_pos)
	return walls_layer.local_to_map(local_pos)

func update_navigation_map() -> void:
	# Since using TileMapLayer navigation, call force_update on ground_layer
	ground_layer.force_update_transform()
	# If using NavigationRegion2D, update polygon as before (optional fallback)

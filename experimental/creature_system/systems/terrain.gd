extends TileMapLayer

# Configuration for the map size (adjust as needed for your large dungeon)
@export var map_width: int = 150
@export var map_height: int = 150

# Initial random fill percentage for walls (0.0 to 1.0)
@export var initial_wall_chance: float = 0.45

# Number of cellular automata iterations
@export var ca_iterations: int = 5

# Terrain set index (assuming 0 is your terrain set with 2 terrains)
@export var terrain_set: int = 0

# Terrain indices (0 for ground, 1 for wall)
@export var ground_terrain: int = 0
@export var wall_terrain: int = 1

# Internal state: 2D array where 0 = ground, 1 = wall
var state: Array = []

# Thread for performant background computation on large maps
var computation_thread: Thread

func _ready() -> void:
	# Initialize the map on ready (or call manually when needed)
	initialize_map()
	start_ca_simulation()

# Initialize the map with random noise
func initialize_map() -> void:
	state = []
	for x in range(map_width):
		var row: Array = []
		for y in range(map_height):
			row.append(1 if randf() < initial_wall_chance else 0)
		state.append(row)
	
	# Apply initial state to the TileMapLayer
	apply_state()

# Apply one full step of cellular automata (synchronous for small maps)
# For large maps, use start_ca_simulation() instead for threading
func apply_ca_step() -> void:
	var new_state: Array = []
	for x in range(map_width):
		var row: Array = state[x].duplicate()
		new_state.append(row)
	
	for x in range(map_width):
		for y in range(map_height):
			var wall_count: int = get_wall_neighbor_count(x, y)
			# Standard cave CA rules: Birth if >4 walls, death if <4, stay same if =4
			if wall_count > 4:
				new_state[x][y] = 1  # Become wall
			elif wall_count < 4:
				new_state[x][y] = 0  # Become ground
			# Else: Stay the same
	
	state = new_state
	apply_state()

# Count wall neighbors (Moore neighborhood, 8 directions)
# Treat out-of-bounds as walls for edge behavior
func get_wall_neighbor_count(x: int, y: int) -> int:
	var count: int = 0
	for dx in [-1, 0, 1]:
		for dy in [-1, 0, 1]:
			if dx == 0 and dy == 0:
				continue
			var nx: int = x + dx
			var ny: int = y + dy
			if nx < 0 or nx >= map_width or ny < 0 or ny >= map_height:
				count += 1  # Out-of-bounds = wall
			elif state[nx][ny] == 1:
				count += 1
	return count

# Apply the current state to the TileMapLayer using batched terrain connects for performance
func apply_state() -> void:
	var ground_cells: Array[Vector2i] = []
	var wall_cells: Array[Vector2i] = []
	
	for x in range(map_width):
		for y in range(map_height):
			var coord: Vector2i = Vector2i(x, y)
			if state[x][y] == 0:
				ground_cells.append(coord)
			else:
				wall_cells.append(coord)
	
	# Clear existing tiles
	clear()
	
	# Batch set ground and wall terrains (autotiling happens automatically)
	set_cells_terrain_connect(ground_cells, terrain_set, ground_terrain)
	set_cells_terrain_connect(wall_cells, terrain_set, wall_terrain)

# Start full CA simulation in a background thread for performance on large maps
# Runs all iterations in thread, then applies final state on main thread
func start_ca_simulation() -> void:
	if computation_thread and computation_thread.is_started():
		return  # Already running
	
	computation_thread = Thread.new()
	computation_thread.start(Callable(self, "_compute_ca_in_thread"))

# Threaded computation of multiple CA steps
func _compute_ca_in_thread() -> void:
	for i in range(ca_iterations):
		var new_state: Array = []
		for x in range(map_width):
			var row: Array = state[x].duplicate()
			new_state.append(row)
		
		for x in range(map_width):
			for y in range(map_height):
				var wall_count: int = get_wall_neighbor_count(x, y)
				if wall_count > 4:
					new_state[x][y] = 1
				elif wall_count < 4:
					new_state[x][y] = 0
				# Else: Stay the same
		
		state = new_state
	
	# Deferred call to apply on main thread
	call_deferred("_finish_ca_simulation")

# Finish by applying state and cleaning up thread
func _finish_ca_simulation() -> void:
	apply_state()
	computation_thread.wait_to_finish()
	computation_thread = null

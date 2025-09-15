extends TileMapLayer


var tile_health: Dictionary = {}
@export var default_health: float = 1
@export var terrain_set_id: int = 0
@export var terrain_id: int = 0

@onready var bullet_collision_player: AudioStreamPlayer2D = $BulletCollision
var thud_sound: AudioStream = preload("res://assets/sounds/thud_2.wav")
var break_sound: AudioStream = preload("res://assets/sounds/break_1.wav")

# batch collection for removals (cleared each frame)
var removed_tiles: Array[Vector2i] = []

func _ready() -> void:
	initialize_tile_health()
	
func _play_sound(sound_player: AudioStreamPlayer2D, stream: AudioStream, location: Vector2, min_pitch_range: float, max_pitch_range: float) -> void:
	if sound_player and stream:
		sound_player.pitch_scale = randf_range(min_pitch_range, max_pitch_range)
		sound_player.position = location
		sound_player.stream = stream
		
		sound_player.play()
	
func initialize_tile_health() -> void:
	var used_cells = get_used_cells()
	for cell in used_cells:
		tile_health[cell] = default_health
		
func damage_tile(tile_pos: Vector2i, damage: float) -> void:
	if tile_health.has(tile_pos):
		tile_health[tile_pos] -= damage
		_play_sound(bullet_collision_player, thud_sound, map_to_local(tile_pos), 0.8, 1.2)
		if tile_health[tile_pos] <= 0:
			queue_remove_tile(tile_pos)
			_play_sound(bullet_collision_player, break_sound, map_to_local(tile_pos), 0.7, 1.3)
			
# queue tile removal for batch removal
func queue_remove_tile(tile_pos: Vector2i) -> void:
	if not removed_tiles.has(tile_pos): # avoid duplicates
		removed_tiles.append(tile_pos)
			
	
func _process(_delta: float) -> void:
	if removed_tiles.size() > 0:
		# batch remove all queue tiles
		set_cells_terrain_connect(removed_tiles, terrain_set_id, -1)
		
		for pos in removed_tiles:
			tile_health.erase(pos)
			
		var unique_neighbors: Dictionary = {}
		for pos in removed_tiles:
			var neighbors = [
				Vector2i(pos.x - 1, pos.y - 1),
				Vector2i(pos.x, pos.y - 1),
				Vector2i(pos.x + 1, pos.y - 1),
				Vector2i(pos.x - 1, pos.y),
				Vector2i(pos.x + 1, pos.y),
				Vector2i(pos.x - 1, pos.y + 1),
				Vector2i(pos.x, pos.y + 1),
				Vector2i(pos.x + 1, pos.y + 1)
			]
			for neighbor in neighbors:
				if get_cell_source_id(neighbor) != -1 and not unique_neighbors.has(neighbor):
					unique_neighbors[neighbor] = true
			
		# batch update unique neighbors
		var neighbor_array: Array = unique_neighbors.keys()
		if neighbor_array.size() > 0:
			set_cells_terrain_connect(neighbor_array, terrain_set_id, terrain_id)
			
		force_update_transform()
		
		removed_tiles.clear()

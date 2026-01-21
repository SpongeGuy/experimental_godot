extends Node

var entity_container: Node2D
var tilemap_layer_name: String = "base"  # Which tilemap layer to use for spawning

var current_wave: int = 0
var wave_active: bool = false
var active_groups: int = 0

# Wave configuration with multiple groups per wave
var wave_configs: Array[Dictionary] = [
	{
		"wave_number": 1,
		"groups": [
			{
				"spawn_delay": 5.0,
				"total_points": 22,
				"min_spawn_delay": 0.5,
				"max_spawn_delay": 7.0,
				"spawn_radius_min": 150.0,
				"spawn_radius_max": 500.0,
				"cluster_spawn": false,
				"cluster_radius_min": 0.0,
				"cluster_radius_max": 0.0,
				"allowed_entities": [
					{"scene": preload("res://entities/creatures/herbivores/grunt/grunt.tscn"), "points": 2, "weight": 2},
					{"scene": preload("res://entities/creatures/herbivores/flea/flea.tscn"), "points": 3, "weight": 0.75},
					{"scene": preload("res://entities/items/stone/stone.tscn"), "points": 1, "weight": 0.25},
				]
			},

			
			{
				"spawn_delay": 0.0,
				"total_points": 2,
				"min_spawn_delay": 0.2,
				"max_spawn_delay": 0.5,
				"spawn_radius_min": 50.0,
				"spawn_radius_max": 150.0,
				"cluster_spawn": false,
				"cluster_radius_min": 0.0,
				"cluster_radius_max": 0.0,
				"allowed_entities": [
					{"scene": preload("res://entities/items/stone/stone.tscn"), "points": 1, "weight": 0.5},
				]
			},
			{
				"spawn_delay": 25.0,
				"total_points": 8,
				"min_spawn_delay": 0.0,
				"max_spawn_delay": 0.1,
				"spawn_radius_min": 50.0,
				"spawn_radius_max": 150.0,
				"cluster_spawn": true,
				"cluster_radius_min": 1.0,
				"cluster_radius_max": 50.0,
				"allowed_entities": [
					{"scene": preload("res://entities/items/crystal.tscn"), "points": 1, "weight": 0.5},
				]
			},
			{
				"spawn_delay": 0.0,
				"total_points": 12,
				"min_spawn_delay": 0.0,
				"max_spawn_delay": 10,
				"spawn_radius_min": 50.0,
				"spawn_radius_max": 500.0,
				"cluster_spawn": false,
				"cluster_radius_min": 0.0,
				"cluster_radius_max": 0.0,
				"allowed_entities": [
					{"scene": preload("res://entities/items/crystal.tscn"), "points": 1, "weight": 0.5},
				]
			},
			
			
		]
	},
	{
		"wave_number": 2,
		"groups": [
			{
				"spawn_delay": 0.0,
				"total_points": 2,
				"min_spawn_delay": 0.2,
				"max_spawn_delay": 0.5,
				"spawn_radius_min": 50.0,
				"spawn_radius_max": 150.0,
				"cluster_spawn": false,
				"cluster_radius_min": 0.0,
				"cluster_radius_max": 0.0,
				"allowed_entities": [
					{"scene": preload("res://entities/items/stone/stone.tscn"), "points": 1, "weight": 0.5},
				]
			},
			{
				"spawn_delay": 2.0,
				"total_points": 10,
				"min_spawn_delay": 0.5,
				"max_spawn_delay": 2.0,
				"spawn_radius_min": 150.0,
				"spawn_radius_max": 500.0,
				"cluster_spawn": false,
				"cluster_radius_min": 0.0,
				"cluster_radius_max": 0.0,
				"allowed_entities": [
					{"scene": preload("res://entities/creatures/herbivores/spike/spike.tscn"), "points": 2, "weight": 2},
					{"scene": preload("res://entities/creatures/herbivores/grunt/grunt.tscn"), "points": 1, "weight": 0.75},
				]
			},
			{
				"spawn_delay": 33.0,
				"total_points": 5,
				"min_spawn_delay": 0.2,
				"max_spawn_delay": 0.5,
				"spawn_radius_min": 200.0,
				"spawn_radius_max": 300.0,
				"cluster_spawn": true,
				"cluster_radius_min": 50.0,
				"cluster_radius_max": 150.0,
				"allowed_entities": [
					{"scene": preload("res://entities/creatures/carnivores/devil/devil.tscn"), "points": 1, "weight": 0.5},
				]
			},
			{
				"spawn_delay": 4.0,
				"total_points": 2,
				"min_spawn_delay": 0.0,
				"max_spawn_delay": 2.0,
				"spawn_radius_min": 50.0,
				"spawn_radius_max": 150.0,
				"cluster_spawn": true,
				"cluster_radius_min": 1.0,
				"cluster_radius_max": 50.0,
				"allowed_entities": [
					{"scene": preload("res://entities/creatures/herbivores/flea/flea.tscn"), "points": 1, "weight": 0.5},
				]
			},
		]
	},
]

func start_wave(wave_number: int) -> void:
	if wave_active:
		push_warning("Wave already active!")
		return
	
	current_wave = wave_number
	wave_active = true
	
	var config = _get_wave_config(wave_number)
	if not config:
		push_error("No config found for wave %s" % wave_number)
		wave_active = false
		return
	
	EventBus.wave_started.emit(wave_number, _calculate_total_points(config))
	
	# Track number of active groups
	active_groups = config.groups.size()
	
	# Spawn all groups in parallel - each runs independently
	for group in config.groups:
		_spawn_group_parallel(group)

func _spawn_group_parallel(group: Dictionary) -> void:
	# This function runs independently for each group
	_spawn_group(group)

func _spawn_group(group: Dictionary) -> void:
	# Wait for group's spawn delay
	if group.spawn_delay > 0.0:
		await get_tree().create_timer(group.spawn_delay).timeout
	
	var points_remaining: int = group.total_points
	var entities_to_spawn: Array[Dictionary] = []
	
	for entity in group.allowed_entities:
		entities_to_spawn.append(entity.duplicate())
	
	# Determine cluster spawn location if needed
	var cluster_center: Vector2 = Vector2.INF
	if group.cluster_spawn:
		cluster_center = _find_valid_spawn_position(
			group.spawn_radius_min, 
			group.spawn_radius_max
		)
		if cluster_center == Vector2.INF:
			push_warning("Could not find cluster center for group")
			_on_group_complete()
			return
	
	# Spawn entities from this group
	while points_remaining > 0 and entities_to_spawn.size() > 0:
		var entity_data = _pick_random_entity(entities_to_spawn)
		if not entity_data or entity_data.points > points_remaining:
			break
		
		var delay = randf_range(group.min_spawn_delay, group.max_spawn_delay)
		await get_tree().create_timer(delay).timeout
		
		var spawn_pos: Vector2
		if group.cluster_spawn:
			spawn_pos = _find_cluster_spawn_position(
				cluster_center,
				group.cluster_radius_min,
				group.cluster_radius_max
			)
		else:
			spawn_pos = _find_valid_spawn_position(
				group.spawn_radius_min,
				group.spawn_radius_max
			)
		
		if spawn_pos != Vector2.INF:
			_spawn_entity(entity_data.scene, spawn_pos)
			points_remaining -= entity_data.points
	
	# This group is done
	_on_group_complete()

func _on_group_complete() -> void:
	active_groups -= 1
	if active_groups <= 0:
		wave_active = false
		EventBus.wave_completed.emit(current_wave)

func _pick_random_entity(entities: Array[Dictionary]) -> Dictionary:
	if entities.is_empty():
		return {}
	
	var total_weight: float = 0.0
	for entity in entities:
		total_weight += entity.weight
	
	var rand_value = randf() * total_weight
	var accumulated_weight: float = 0.0
	
	for entity in entities:
		accumulated_weight += entity.weight
		if rand_value <= accumulated_weight:
			return entity
	
	return entities[0]

func _find_valid_spawn_position(radius_min: float, radius_max: float) -> Vector2:
	var tilemap = _get_tilemap()
	if not tilemap:
		push_error("Tilemap layer '%s' not found in WorldManager" % tilemap_layer_name)
		return Vector2.INF
	
	return WorldManager.find_valid_spawn_position(radius_min, radius_max, tilemap)

func _find_cluster_spawn_position(cluster_center: Vector2, radius_min: float, radius_max: float) -> Vector2:
	var tilemap = _get_tilemap()
	if not tilemap:
		push_warning("Tilemap not found, falling back to cluster center")
		return cluster_center
	
	return WorldManager.find_cluster_spawn_position(cluster_center, radius_min, radius_max, tilemap)

func _spawn_entity(scene: PackedScene, position: Vector2) -> void:
	var entity = scene.instantiate()
	entity.global_position = position
	entity_container.add_child(entity)

func _get_tilemap() -> TileMapLayer:
	return WorldManager.tilemap_layers.get(tilemap_layer_name)

func _get_wave_config(wave_number: int) -> Dictionary:
	for config in wave_configs:
		if config.wave_number == wave_number:
			return config
	return {}

func _calculate_total_points(config: Dictionary) -> int:
	var total = 0
	for group in config.groups:
		total += group.total_points
	return total

func add_wave_config(wave_number: int, groups: Array[Dictionary]) -> void:
	wave_configs.append({
		"wave_number": wave_number,
		"groups": groups
	})

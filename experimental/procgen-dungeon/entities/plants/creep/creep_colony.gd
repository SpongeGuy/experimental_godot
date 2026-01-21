class_name CreepColony
extends Node2D

signal colony_destroyed
signal colony_merged(other_colony: CreepColony)
signal node_spawned(node: CreepNode)

var colony_id: int = -1
var nodes: Dictionary[Vector2i, CreepNode] = {}
var total_nutrition: float = 0
var total_health: float = 0
var center_of_mass: Vector2 = Vector2.ZERO

var target_entity: Node2D = null
var threat_level: float = 0
var aggression: float = 0.5 # how likely to spawn enemies or attack
var growth_priority: float = 0.5 # growth vs defense

var entities_in_creep: Dictionary[Entity, float] = {}
const CONSUMPTION_TIME: float = 1.0

func _ready() -> void:
	colony_id = randi()
	CreepMaster.register_colony(self)
	
func _process(delta: float) -> void:
	_update_colony_stats()
	_update_colony_intelligence(delta)
	_update_entity_consumption(delta)

func add_node(node: CreepNode) -> void:
	nodes[node.cell_position] = node
	node.colony = self
	node.creep_node_destroyed.connect(_on_node_destroyed)
	node.creep_nutrition_changed.connect(_on_node_nutrition_changed)
	
func remove_node(node: CreepNode) -> void:
	nodes.erase(node.cell_position)
	if nodes.is_empty():
		_destroy_colony()
		
func has_node_at(pos: Vector2i) -> bool:
	return nodes.has(pos)
	
func get_node_at(pos: Vector2i) -> CreepNode:
	return nodes.get(pos, null)
	
func spawn_node_at(pos: Vector2i, node_type: CreepNode.NodeType) -> CreepNode:
	if has_node_at(pos):
		return nodes[pos]
		
	var cell = WorldManager.get_cell(pos)
	if cell == null or cell.type == Cell.CellType.HARD_WALL:
		return null
	
	var node: CreepNode = CreepNode.new(pos, self, node_type)
	add_child(node)
	add_node(node)
	
	node_spawned.emit(node)
	return node
	
func _update_entity_consumption(delta: float) -> void:
	var entities_to_remove: Array[Entity] = []
	
	for entity in entities_in_creep.keys():
		if not is_instance_valid(entity):
			entities_to_remove.append(entity)
			continue
			
		entities_in_creep[entity] += delta
		
		if entities_in_creep[entity] >= CONSUMPTION_TIME:
			_consume_entity(entity)
			entities_to_remove.append(entity)
			
	for entity in entities_to_remove:
		entities_in_creep.erase(entity)
		
func _consume_entity(entity: Entity) -> void:
	# colony consumes an entity after it stayed too long
	if not is_instance_valid(entity):
		return
		
	var nutrition_value = entity.nutrition
	
	var node = _get_random_nearby_node(WorldManager.world_to_cell(entity.position, WorldManager.tilemap_layers["base"]), 2)
	if node:
		node.nutrition += nutrition_value
	
	entity.be_consumed_by_creep(self)
	
func is_entity_in_creep(entity: Entity) -> bool:
	return entities_in_creep.has(entity)
	
func get_entity_time_in_creep(entity: Entity) -> float:
	return entities_in_creep.get(entity, 0.0)
	
func register_entity_entered(entity: Entity) -> void:
	if not entities_in_creep.has(entity):
		entities_in_creep[entity] = 0.0
		entity.is_in_creep = true
		
func register_entity_exited(entity: Entity) -> void:
	entities_in_creep.erase(entity)
	entity.is_in_creep = false

func distribute_nutrition(amount: float) -> void:
	var share = amount / nodes.size()
	for node in nodes.values():
		node.add_nutrition(share)
		
func request_node_type(pos: Vector2i) -> CreepNode.NodeType:
	var nearby_spawners = _count_nearby_type(pos, CreepNode.NodeType.SPAWNER, 5)
	var nearby_fruits = _count_nearby_type(pos, CreepNode.NodeType.FRUIT_BEARER, 5)
	var nearby_hyper = _count_nearby_type(pos, CreepNode.NodeType.HYPER_SEED, 8)
	
	if threat_level > 0.7 and nearby_spawners < 2:
		return CreepNode.NodeType.SPAWNER
	
	if nodes.size() < 20 and nearby_hyper < 1:
		return CreepNode.NodeType.HYPER_SEED
	
	if nearby_fruits < 2 and randf() < 0.3:
		return CreepNode.NodeType.FRUIT_BEARER
	
	return CreepNode.NodeType.MATURE
	
func trigger_growth_burst(center: Vector2i, radius: int) -> void:
	for y in range(-radius, radius + 1):
		for x in range(-radius, radius + 1):
			var offset = Vector2i(x, y)
			if offset.length() <= radius:
				var target_pos = center + offset
				var cell: Cell = WorldManager.get_cell(target_pos)
				
				if cell and cell.is_walkable and not has_node_at(target_pos):
					spawn_node_at(target_pos, CreepNode.NodeType.GROWING)

func _get_producing_ratio() -> float:
	# returns the ratio of producing nodes (ones who produce nutrition) to those who do not in the colony
	var amount_of_producing: int = 0
	for node in nodes:
		if nodes[node].node_type == CreepNode.NodeType.MATURE:
			amount_of_producing += 1
	return float(amount_of_producing) / float(nodes.size())

func merge_with(other_colony: CreepColony) -> void:
	# Absorb another colony
	for node in other_colony.nodes.values():
		add_node(node)
	
	colony_merged.emit(other_colony)
	other_colony.queue_free()
	
func _update_colony_stats() -> void:
	total_nutrition = 0.0
	total_health = 0.0
	var pos_sum = Vector2.ZERO
	
	for node in nodes.values():
		total_nutrition += node.nutrition
		total_health += node.health
		pos_sum += node.world_position
	
	if nodes.size() > 0:
		center_of_mass = pos_sum / nodes.size()
		
func _update_colony_intelligence(delta: float) -> void:
	# Assess threats
	var nearby_enemies = _find_nearby_enemies()
	threat_level = min(nearby_enemies.size() / 5.0, 1.0)
	
	# Adjust behavior
	if total_nutrition < nodes.size() * 20.0:
		growth_priority = 0.3  # Focus on defense
		aggression = 0.7
	elif nodes.size() < 10:
		growth_priority = 0.9  # Focus on growth
		aggression = 0.2
	else:
		growth_priority = 0.5
		aggression = 0.5
		

		
func _find_nearby_enemies() -> Array[Node2D]:
	var enemies: Array[Node2D] = []
	var search_radius = 200.0
	
	enemies = WorldManager.get_entities_in_radius(
		center_of_mass,
		search_radius,
		WorldManager.tilemap_layers["base"]
	)
	
	return enemies

func _count_nearby_type(pos: Vector2i, type: CreepNode.NodeType, radius: int) -> int:
	var count = 0
	for node in nodes.values():
		if node.node_type == type:
			var dist = (node.cell_position - pos).length()
			if dist <= radius:
				count += 1
	return count
	
func _get_random_nearby_node(pos: Vector2i, radius: int) -> CreepNode:
	var nodes_copy: Dictionary = nodes.duplicate()
	for node in nodes.values():
		var dist = (node.cell_position - pos).length()
		if dist <= radius:
			return node
	return null
			

func _destroy_colony() -> void:
	pass
	
func _on_node_destroyed(node: CreepNode) -> void:
	pass
	
func _on_node_nutrition_changed(old: float, new: float) -> void:
	pass

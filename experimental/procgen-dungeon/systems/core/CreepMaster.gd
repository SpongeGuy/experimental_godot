extends Node

var colonies: Dictionary = {}  # int -> CreepColony
var next_colony_id: int = 0

func _ready() -> void:
	pass

func register_colony(colony: CreepColony) -> void:
	colonies[next_colony_id] = colony
	colony.colony_id = next_colony_id
	next_colony_id += 1

func unregister_colony(colony: CreepColony) -> void:
	colonies.erase(colony.colony_id)

func get_colony_at_position(cell_pos: Vector2i) -> CreepColony:
	for colony in colonies.values():
		if colony.has_node_at(cell_pos):
			return colony
	return null

func spawn_initial_creep(world_pos: Vector2, tilemap: TileMapLayer) -> CreepColony:
	var cell_pos = WorldManager.world_to_cell(world_pos, tilemap)
	
	var colony = CreepColony.new()
	EntityManager.add_entity_to_world(colony)
	
	# Spawn initial 3x3 cluster
	for y in range(-1, 2):
		for x in range(-1, 2):
			colony.spawn_node_at(cell_pos + Vector2i(x, y), CreepNode.NodeType.MATURE)
	
	return colony

func check_colony_adjacency() -> void:
	# Merge colonies that touch
	var colony_list = colonies.values()
	
	for i in range(colony_list.size()):
		for j in range(i + 1, colony_list.size()):
			var colony_a = colony_list[i]
			var colony_b = colony_list[j]
			
			if _colonies_are_adjacent(colony_a, colony_b):
				colony_a.merge_with(colony_b)
				break

func _colonies_are_adjacent(a: CreepColony, b: CreepColony) -> bool:
	for pos_a in a.nodes.keys():
		var neighbors = [
			pos_a + Vector2i.UP,
			pos_a + Vector2i.DOWN,
			pos_a + Vector2i.LEFT,
			pos_a + Vector2i.RIGHT
		]
		
		for neighbor_pos in neighbors:
			if b.has_node_at(neighbor_pos):
				return true
	
	return false

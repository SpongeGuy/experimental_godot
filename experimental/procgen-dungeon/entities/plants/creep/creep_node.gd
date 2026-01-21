class_name CreepNode
extends Node2D

signal creep_node_destroyed(node: CreepNode)
signal creep_node_consumed_entity(entity: Entity)
signal creep_nutrition_changed(new_value: float)
signal creep_node_type_changed(old_type: NodeType, new_type: NodeType)

var creep_mature_img: Texture2D = preload("res://assets/sprites/debug/creep_mature.png")
var creep_growing_img: Texture2D = preload("res://assets/sprites/debug/creep_growing.png")
var creep_fruiting_img: Texture2D = preload("res://assets/sprites/debug/creep_fruiting.png")
var creep_indestructible_img: Texture2D = preload("res://assets/sprites/debug/creep_indestructible.png")
var creep_spawner_img: Texture2D = preload("res://assets/sprites/debug/creep_spawner.png")
var creep_spore_img: Texture2D = preload("res://assets/sprites/debug/creep_spore.png")
var creep_hyper_img: Texture2D = preload("res://assets/sprites/debug/creep_hyper.png")

var fruit_scene = preload("res://entities/items/fruits/greeg.tscn")

enum NodeType {
	NONE,
	GROWING, 
	MATURE,
	HYPER_SEED,
	SPAWNER,
	SPORE_PRODUCER,
	FRUIT_BEARER,
	INDESTRUCTIBLE,
}

var directions = [
		Vector2i.UP, Vector2i.DOWN,
		Vector2i.LEFT, Vector2i.RIGHT
	]

var colony: CreepColony = null
var cell_position: Vector2i
var world_position: Vector2

# stats
var node_type: NodeType = NodeType.GROWING
var health: float = 10.0
var max_health: float = 10.0
var nutrition: float = 0.0
var max_nutrition: float = 100.0
var growth_progress: float = 0.0
var age: float = 0.0
var debug_flags: Dictionary = {
	
}

# behavior timers
var spread_attempt_timer: float = 0.0
var spread_cooldown: float = 12.0
var last_consumption_check: float = 0.0

var behavior_timer: float = 0.0

var hitbox: Area2D
var hurtbox: Area2D
var sprite: Sprite2D

func _init(pos: Vector2i, parent_colony: CreepColony, type: CreepNode.NodeType) -> void:
	cell_position = pos
	colony = parent_colony
	node_type = type
	position = WorldManager.cell_to_world(cell_position, WorldManager.tilemap_layers["base"])
	
func _setup_visuals() -> void:
	sprite = Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(sprite)
	
func _setup_colliders() -> void:
	hitbox = Area2D.new()
	var hitbox_shape: CollisionShape2D = CollisionShape2D.new()
	hitbox_shape.shape = RectangleShape2D.new()
	hitbox_shape.shape.size = Vector2(16, 16)
	
	hurtbox = Area2D.new()
	var hurtbox_shape: CollisionShape2D = CollisionShape2D.new()
	hurtbox_shape.shape = RectangleShape2D.new()
	hurtbox_shape.shape.size = Vector2(16, 16)
	
	add_child(hitbox)
	add_child(hurtbox)
	
	hitbox.add_child(hitbox_shape)
	hurtbox.add_child(hurtbox_shape)
	
	hitbox.collision_layer = 8  # Creep layer
	hurtbox.collision_mask = (1 << 2) | (1 << 4)   # Entities and creatures

	hurtbox.body_entered.connect(_body_entered_hurtbox)
	hurtbox.body_exited.connect(_body_exited_hurtbox)
	
	name = "CreepNode"

func _ready() -> void:
	_setup_visuals()
	_setup_colliders()
	_consume_tile_at_position()
	_update_visual_for_type()
	
func _consume_tile_at_position() -> void:
	"""
	Destroy the wall tile at this position (creep eats walls)
	"""
	var cell: Cell = WorldManager.get_cell(cell_position)
	if cell == null:
		return

	# If there's a soft wall, destroy it
	if cell.type == Cell.CellType.SOFT_WALL:
		WorldManager.destroy_cell(cell_position, WorldManager.tilemap_layers["base"])
		# Gain nutrition from consuming wall
		add_nutrition(20.0)
	elif cell.type == Cell.CellType.GROUND:
		WorldManager.destroy_cell(cell_position, WorldManager.tilemap_layers["base"])

	# Mark cell as having creep
	cell = WorldManager.get_cell(cell_position)
	if cell:
		cell.creep_level = 1.0


func _process(delta: float) -> void:
	age += delta
	
	
	match node_type:
		NodeType.MATURE:
			_process_mature(delta)
		NodeType.GROWING:
			_process_growth(delta)
		NodeType.HYPER_SEED:
			_process_hyper_seed(delta)
		NodeType.SPAWNER:
			_process_spawner(delta)
		NodeType.FRUIT_BEARER:
			_process_fruit_bearer(delta)
		NodeType.INDESTRUCTIBLE:
			_process_indestructible(delta)
		NodeType.SPORE_PRODUCER:
			_process_spore_producer(delta)
	
	
	
func _do_absorption(delta: float, buffer: float = 20.0) -> void:
	var rate_per_second: float = 1.0
	if fmod(age, rate_per_second) < delta:
		_absorb_nutrition_from_neighbors(buffer)
		
		
func _process_growth(delta: float) -> void:
	var rate_per_second: float = 1.0
	if fmod(age, rate_per_second) < delta:
		if _absorb_nutrition_from_neighbors(10.0):
			growth_progress += 0.1
	growth_progress += delta * 0.01
	nutrition -= delta * randf_range(0, 0.2)
	if growth_progress >= 1.0 and nutrition > 10.0:
		_change_type(_determine_mature_type())
		
func _process_mature(delta: float) -> void:
	_do_absorption(delta)
	# spread mass
	spread_attempt_timer += delta
	nutrition += delta * randf_range(0, 1)
	if spread_attempt_timer > spread_cooldown:
		spread_attempt_timer = 0.0 - randf_range(0, 5)
		if age > 30.0 and nutrition > 30.0:
			_attempt_spread()
		
	# change into indestructible if nutritive
	if age > 250.0 and nutrition > 100.0:
		_change_type(NodeType.INDESTRUCTIBLE)

func _process_spore_producer(delta: float) -> void:
	_do_absorption(delta)

func _process_hyper_seed(delta: float) -> void:
	_do_absorption(delta)
	nutrition -= delta * randf_range(0, 0.2)
		
func _process_spawner(delta: float) -> void:
	_do_absorption(delta)
	# spawn an entity every once in a while, probably scaling with aggression?
	if nutrition > 50.0 and age > 30.0:
		_spawn_zombie()
		nutrition -= 50.0
	nutrition -= delta * randf_range(0, 0.2)
		
func _process_fruit_bearer(delta: float) -> void:
	_do_absorption(delta)
	var fruit_growth_buffer: float = 25.0
	var check_cooldown: float = 20.0
	nutrition -= delta * randf_range(0, 0.2)
	behavior_timer += delta
	if behavior_timer > fruit_growth_buffer:
		behavior_timer = 0.0
		if nutrition > 25.0 and age > 50.0:
			_grow_fruit(_get_vector_facing_away_from_creep())
			nutrition -= 25.0
		
	# check to see if all surrounding sides are blocked by creep
	
	elif behavior_timer > check_cooldown:
		for dir in directions:
			var target_pos = cell_position + dir
			var target_cell: Cell = WorldManager.get_cell(target_pos)
			if target_cell:
				if target_cell.creep_level == 0.0:
					return
					
		_change_type(NodeType.MATURE)

func _get_vector_facing_away_from_creep() -> Vector2:
	# takes adjacent directions and returns a vector which faces away from adjacent creep nodes
	var occupied_directions: Array = []
	for dir in directions:
		var target_pos = cell_position + dir
		var target_cell: Cell = WorldManager.get_cell(target_pos)
		if target_cell:
			if target_cell.creep_level > 0.0:
				occupied_directions.append(dir)
					
	if occupied_directions.is_empty():
		var angle = randf() * TAU
		return Vector2.from_angle(angle)
		
	var sum: Vector2 = Vector2.ZERO
	for dir in occupied_directions:
		sum += Vector2(dir.x, dir.y)
		
	var normalized = sum.normalized()
	return -normalized
			

func _process_indestructible(delta: float) -> void:
	if nutrition < 60.0:
		_change_type(colony.request_node_type(cell_position))
		
func take_damage(amount: float, source: Node = null) -> void:
	if node_type != NodeType.INDESTRUCTIBLE:
		health -= amount
	
	if health <= 0.0:
		_die(source)
	
func _die(source: Node = null) -> void:
	match node_type:
		NodeType.SPORE_PRODUCER:
			_release_spores()
		NodeType.HYPER_SEED:
			_explode_nutrition()
			
	var cell: Cell = WorldManager.get_cell(cell_position)
	if cell:
		cell.creep_level = 0.0
		
	creep_node_destroyed.emit(self)
	
	if colony:
		colony.remove_node(self)
		
	queue_free()
	
func add_nutrition(amount: float) -> void:
	var old_nutrition = nutrition
	nutrition = min(nutrition + amount, max_nutrition)
	
	if old_nutrition != nutrition:
		creep_nutrition_changed.emit(nutrition)
		_update_visual_saturation()
		
func _explode_nutrition() -> void:
	pass
		
		
func _attempt_spread() -> void:
	var nutrition_requirement_to_destroy_walls: float = 80.0	
	if nutrition < 25.0:
		return
		
	directions.shuffle()
	
	for dir in directions:
		var target_pos = cell_position + dir
		var target_cell: Cell = WorldManager.get_cell(target_pos)
		if target_cell:
			if target_cell.type == Cell.CellType.SOFT_WALL and nutrition < nutrition_requirement_to_destroy_walls:
				# only consume soft walls if the node is very healthy
				continue
			debug_flags["stats"] = str(target_pos, " ", target_cell.creep_level)
			if target_cell.creep_level == 0.0:
				if colony:
					debug_flags["spread"] = str(Time.get_ticks_msec() / 1000, " ", target_cell)
					colony.spawn_node_at(target_pos, NodeType.GROWING)
					nutrition -= 10.0
					break
				
func _absorb_nutrition_from_neighbors(buffer: float = 20.0) -> bool:
	if nutrition >= max_nutrition:
		return false
		
	var neighbor_positions = [
		cell_position + Vector2i.UP,
		cell_position + Vector2i.DOWN,
		cell_position + Vector2i.LEFT,
		cell_position + Vector2i.RIGHT,
	]
	
	for neighbor_pos in neighbor_positions:
		if colony and colony.has_node_at(neighbor_pos):
			var neighbor = colony.get_node_at(neighbor_pos)
			if neighbor and neighbor.nutrition > nutrition + buffer:
				var transfer = 5.0
				neighbor.nutrition -= transfer
				add_nutrition(transfer)
				return true
	return false
				
func _determine_mature_type() -> NodeType:
	if colony:
		return colony.request_node_type(cell_position)
		
	var types = [
		NodeType.NONE,
		NodeType.GROWING, 
		NodeType.MATURE,
		NodeType.HYPER_SEED,
		NodeType.SPAWNER,
		NodeType.SPORE_PRODUCER,
		NodeType.FRUIT_BEARER,
		NodeType.INDESTRUCTIBLE,
	]
	return types[randi() % types.size()]
	
func _change_type(new_type: NodeType) -> void:
	var old_type = node_type
	node_type = new_type
	
	match new_type:
		NodeType.MATURE:
			max_health = 15.0
			max_nutrition = 100.0
		NodeType.HYPER_SEED:
			max_health = 30.0
			max_nutrition = 200.0
		NodeType.SPAWNER:
			max_health = 25.0
			max_nutrition = 150.0
		NodeType.SPORE_PRODUCER:
			max_health = 10.0
			max_nutrition = 80.0
		NodeType.FRUIT_BEARER:
			max_health = 20.0
			max_nutrition = 120.0
			
	health = max_health
	_update_visual_for_type()
	creep_node_type_changed.emit(old_type, new_type)
	
func _trigger_hyper_growth() -> void:
	if colony: 
		colony.trigger_growth_burst(cell_position, 5)
	nutrition = 0.0
	
func _spawn_zombie() -> void:
	pass
	
func _release_spores() -> void:
	pass
	
func _grow_fruit(direction: Vector2) -> void:
	var fruit: Entity = fruit_scene.instantiate()
	var force: float = 250
	fruit.apply_central_impulse(direction * force * randf_range(1, 1.5))
	fruit.position = position
	EntityManager.add_entity_to_world(fruit)
	
func _play_consumption_animation(entity: Entity) -> void:
	pass
	
func _update_visual_for_type() -> void:
	match node_type:
		NodeType.MATURE:
			sprite.texture = creep_mature_img
		NodeType.HYPER_SEED:
			sprite.texture = creep_hyper_img
		NodeType.SPAWNER:
			sprite.texture = creep_spawner_img
		NodeType.SPORE_PRODUCER:
			sprite.texture = creep_spore_img
		NodeType.FRUIT_BEARER:
			sprite.texture = creep_fruiting_img
		NodeType.GROWING:
			sprite.texture = creep_growing_img
		NodeType.INDESTRUCTIBLE:
			sprite.texture = creep_indestructible_img
				
func _update_visual_saturation() -> void:
	# change node graphics based on nutrition
	pass

func _body_entered_hurtbox(body: Node2D) -> void:
	print(body, cell_position)
	if not body is Entity:
		return
		
	var entity = body as Entity
	if colony: colony.register_entity_entered(entity)
	

func _body_exited_hurtbox(body: Node2D) -> void:
	print(body, cell_position)
	if not body is Entity: return
	
	var entity = body as Entity
	if colony:
		var still_in_creep = false
		for node in colony.nodes.values():
			if node == self:
				continue
				
			if node.hurtbox.overlaps_body(entity):
				still_in_creep = true
				break
				
		if not still_in_creep:
			colony.register_entity_exited(entity)

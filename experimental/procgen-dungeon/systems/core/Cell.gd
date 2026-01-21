class_name Cell
extends RefCounted

signal destroyed(global_pos: Vector2i, flags: int)

enum DestroyFlag {
	NONE = 0,
	EXPLODED = 1 << 0, # bomb blast
	OOZE_EATEN = 1 << 1, # anthurium spread
	BROKEN = 1 << 2, # creature destroyed it by some means
}

var creep_level: float = 0.0
var entities_on_cell: Array[Entity] = []

signal entity_entered(entity: Entity)
signal entity_exited(entity: Entity)

func add_entity(entity: Entity) -> void:
	if not entities_on_cell.has(entity):
		entities_on_cell.append(entity)
		entity_entered.emit(entity)

func remove_entity(entity: Entity) -> void:
	var idx = entities_on_cell.find(entity)
	if idx >= 0:
		entities_on_cell.remove_at(idx)
		entity_exited.emit(entity)
		
func has_entity() -> bool:
	return entities_on_cell.size() > 0

func get_entities_of_id_class(id_class: String) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in entities_on_cell:
		if is_instance_valid(entity) and entity.identification.entity_class == id_class:
			result.append(entity)
	return result
	
func get_entities_of_id_type(id_type: String) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in entities_on_cell:
		if is_instance_valid(entity) and entity.identification.entity_type == id_type:
			result.append(entity)
	return result
	
func get_entities_of_id_faction(id_faction: EntityIdentification.CreatureFactions) -> Array[Entity]:
	var result: Array[Entity] = []
	for entity in entities_on_cell:
		if is_instance_valid(entity) and entity.identification.entity_faction == id_faction:
			result.append(entity)
	return result


enum CellType {NONE, GROUND, SOFT_WALL, HARD_WALL}

var position: Vector2i
var nav_weight: float
var type: CellType
var health: float

var is_walkable: bool = false

func _init(pos: Vector2i, cell_type: CellType) -> void:
	position = pos
	type = cell_type
	
	if cell_type == CellType.GROUND:
		is_walkable = true
	
func take_damage(amount: int, flag: int = DestroyFlag.NONE) -> void:
	if type != CellType.SOFT_WALL:
		return
	health = max(health - amount, 0)
	if health <= 0:
		_die(flag)

func _die(flag: int) -> void:
	type = CellType.NONE
	health = 0
	destroyed.emit(position, flag)


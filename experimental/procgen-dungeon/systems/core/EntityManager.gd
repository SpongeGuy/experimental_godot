extends Node

var _world: World
var entity_types: Dictionary = {}

func add_entity_type_to_register(entity_type: String, entity_class: String):
	assert(entity_type, "Creature type registered with no entry!")
	assert(entity_class, "Creature class registered with no entry!")
	
	if not entity_types.has(entity_type):
		entity_types[entity_type] = entity_class

func add_entity_to_world(entity: Node2D) -> void:
	_get_world()
	if not _world.entities:
		return
	_world.entities.add_child(entity)
	
func get_world() -> World:
	if not _world:
		_get_world()
	return _world
	
func _get_world() -> void:
	if not _world:
		for child in get_tree().root.get_children():
			if child is WorldManager:
				_world = child.world

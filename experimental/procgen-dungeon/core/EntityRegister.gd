extends Node


var entity_types: Dictionary = {}

func add_entity_type_to_register(entity_type: String, entity_class: String):
	assert(entity_type, "Creature type registered with no entry!")
	assert(entity_class, "Creature class registered with no entry!")
	
	if not entity_types.has(entity_type):
		entity_types[entity_type] = entity_class

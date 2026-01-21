extends Node


var entity_container: Node2D



func add_entity_to_world(entity: Node2D) -> void:
	if not entity_container:
		return
	entity_container.add_child(entity)

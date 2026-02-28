extends Node
class_name GameManager


static var entity_container: Node2D

static func get_entity_container():
	if entity_container:
		return entity_container
	return null

extends Node


var entity_container: Node2D

var player_character: Node2D

func add_entity_to_world(entity: Node2D) -> void:
	if not entity_container:
		return
	entity_container.add_child(entity)

func get_player() -> Node2D:
	if is_instance_valid(player_character):
		return player_character
	return null

@tool
extends BTAction

@export var entity: PackedScene
@export var relative_position: Vector2 = Vector2.ZERO

func _generate_name() -> String:
	return "Summon object %s at relative position %s" % [
		entity,
		relative_position,
	]

func _tick(_delta: float) -> Status:
	if entity:
		var child = entity.instantiate()
		child.global_position = agent.global_position + relative_position
		agent.get_tree().current_scene.add_child(child)
		return SUCCESS
	return FAILURE

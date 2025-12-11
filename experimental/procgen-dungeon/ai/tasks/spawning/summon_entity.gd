@tool
extends BTAction

@export_file("*.tscn") var entity_path: String
@export var relative_position: Vector2 = Vector2.ZERO

func _generate_name() -> String:
	return "Summon object %s at relative position %s" % [
		entity_path.get_file().get_basename() if entity_path else "nothing",
		relative_position,
	]

func _tick(_delta: float) -> Status:
	if entity_path.is_empty():
		return FAILURE
		
	var scene := load(entity_path) as PackedScene
	if not scene:
		push_error("Failed to load scene: %s" % entity_path)
		return FAILURE
	
	var child := scene.instantiate()
	child.global_position = agent.global_position + relative_position
	EntityManager.add_entity_to_world(child)
	return SUCCESS

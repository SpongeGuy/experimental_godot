@tool
extends BTAction

@export_file("*.tscn") var entity_path: String
@export var relative_position: Vector2 = Vector2.ZERO
@export var force: float = 1

func _generate_name() -> String:
	return "Summon object %s at relative position %s with random directional force %s" % [
		entity_path.get_file().get_basename() if entity_path else "nothing",
		relative_position,
		force,
	]
	
func apply_random_force(body: RigidBody2D, magnitude: float) -> void:
	var rng = RandomNumberGenerator.new()
	rng.randomize()  # Seed with random value for better randomness
	var angle: float = rng.randf_range(0, TAU)
	var force: Vector2 = Vector2(magnitude, 0).rotated(angle)
	body.apply_force(force)

func _tick(_delta: float) -> Status:
	if entity_path.is_empty():
		return FAILURE
		
	var scene := load(entity_path) as PackedScene
	if not scene:
		push_error("Failed to load scene: %s" % entity_path)
		return FAILURE
	
	var child := scene.instantiate()
	agent.get_tree().current_scene.add_child(child)
	child.global_position = agent.global_position + relative_position + Vector2(randf_range(-1, 1), randf_range(-1, 1))

	if child is RigidBody2D:
		child.gravity_scale = 0.0
		child.freeze = false
		child.sleeping = false
		apply_random_force(child, force)
	return SUCCESS

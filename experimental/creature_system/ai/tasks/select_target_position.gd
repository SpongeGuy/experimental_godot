@tool
extends BTAction

@export var range_min: float

@export var range_max: float

# blackboard variable storing position
@export var target_position_var: StringName = &"target_pos"

func _generate_name() -> String:
	return "SelectTargetPosition range: [%s, %s] -> %s" % [
		range_min, range_max,
		LimboUtility.decorate_var(target_position_var)
	]

func _tick(delta: float) -> Status:
	var target_pos: Vector2
	var is_good_position: bool = false
	while not is_good_position:
		var angle: float = randf() * TAU
		var rand_distance: float = randf_range(range_min, range_max)
		target_pos = agent.global_position + Vector2(sin(angle), cos(angle)) * rand_distance
		is_good_position = true
	blackboard.set_var(target_position_var, target_pos)
		
	return SUCCESS

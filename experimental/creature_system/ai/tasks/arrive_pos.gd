@tool
extends BTAction

@export var target_position_var := &"target_pos"

@export var speed_var := &"speed"

@export var tolerance := 50.0

func _generate_name() -> String:
	return "Arrive pos: %s" % [
		LimboUtility.decorate_var(target_position_var)
	]
	
func _enter() -> void:
	blackboard.set_var(speed_var, agent.creature_stats.movement_speed)

func _tick(delta: float) -> Status:
	var target_pos = blackboard.get_var(target_position_var, Vector2.ZERO)
	if target_pos.distance_to(agent.global_position) < tolerance:
		return SUCCESS
	
	var speed: float = blackboard.get_var(speed_var, 200.0)
	var dist: float = absf(target_pos.x - agent.global_position.x)
	var dir: Vector2 = agent.global_position.direction_to(target_pos)
	
	var desired_velocity: Vector2 = dir.normalized() * speed
	agent.move(desired_velocity)
	return RUNNING

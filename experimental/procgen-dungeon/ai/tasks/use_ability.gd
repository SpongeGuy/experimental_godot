@tool
extends BTAction

const ability_types: Array = []

@export_enum(
	"ability_p", 
	"ability_t", 
	"ability_u", 
	"ability_1", 
	"ability_2", 
	"ability_3", 
	"ability_4") var ability: String
	
func _generate_name() -> String:
	return "Use %s" % [ability]

func _tick(delta: float) -> Status:
	if agent is not Entity:
		return FAILURE
	var activation_direction: Vector2 = (blackboard.get_var("target_entity").global_position - agent.global_position).normalized()
	if not activation_direction:
		return FAILURE
	if agent.abilities[ability].try_activate(agent, activation_direction):
		return SUCCESS
	else:
		return FAILURE

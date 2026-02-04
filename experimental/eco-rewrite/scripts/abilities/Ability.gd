extends Resource
class_name Ability

## base class for all ability effects
## this allows abilities to be data-driven and easily configured in the inspector

func execute(user: Node2D, item: Node2D) -> void:
	push_error("AbilityEffect.execute() must be overridden in child class")
	
func can_execute(user: Node2D, item: Node2D) -> bool:
	return true
	
func get_description() -> String:
	return "No description"
	
# useful for cleanup, effects, or chaining abilities
func on_complete(user: Node2D, item: Node2D) -> void:
	pass

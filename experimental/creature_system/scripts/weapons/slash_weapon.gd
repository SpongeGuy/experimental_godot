extends Weapon

func _ready() -> void:
	super._ready()
	_instantiate_cooldown_timer()
	
func can_activate() -> bool:
	return cooldown_timer.is_stopped()
	
func _perform_attack(target: Node2D) -> void:
	pass

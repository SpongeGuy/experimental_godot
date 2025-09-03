extends Weapon

func _ready() -> void:
	super._ready()
	_instantiate_cooldown_timer()
	
func can_activate() -> bool:
	return cooldown_timer.is_stopped()
	
func _perform_attack(target: Node2D) -> void:
	cooldown_timer.start()
	var projectile = preload("res://nodes/projectile/pellet.tscn").instantiate()
	var direction = (target.position - creature.position).normalized()
	projectile.position = creature.position
	projectile.velocity = direction * weapon_data.base_stats["base_velocity"] if weapon_data else direction * 1500
	projectile.rotation = atan2(target.position.y - creature.position.y, target.position.x - creature.position.x)
	get_tree().root.add_child(projectile)
	

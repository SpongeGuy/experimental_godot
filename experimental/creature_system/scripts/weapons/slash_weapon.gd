extends Weapon

var projectile: Area2D = preload("res://nodes/projectile/slash.tscn").instantiate()

func _ready() -> void:
	super._ready()
	_instantiate_cooldown_timer()
	get_parent().call_deferred("add_child", projectile)

func can_activate() -> bool:
	return cooldown_timer.is_stopped()
	
func _perform_attack(target: Node2D) -> void:
	cooldown_timer.start()
	projectile.animator.speed_scale = creature.creature_stats.attack_speed
	projectile.swing()

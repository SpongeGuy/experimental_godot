extends Weapon

@onready var shot_sound: AudioStream = preload("res://assets/sounds/pellet_shot_1.sfxr")

func _ready() -> void:
	if !weapon_data.base_stats.has("base_velocity"):
		weapon_data.base_stats["base_velocity"] = 250.0
	
	if !weapon_data.base_stats.has("base_attack_speed"):
		weapon_data.base_stats["base_attack_speed"] = 0.2
	
	super._ready()
	_instantiate_cooldown_timer()
	
	
func can_activate() -> bool:
	return cooldown_timer.is_stopped()
	
func _perform_attack(target: Node2D) -> void:
	cooldown_timer.start()
	var projectile = preload("res://nodes/projectile/pellet.tscn").instantiate()
	var direction = (target.position - creature.position).normalized()
	projectile.position = creature.position
	print(projectile.position, creature.position)
	projectile.velocity = direction * weapon_data.base_stats["base_velocity"] if weapon_data else direction * 1500
	projectile.rotation = atan2(target.position.y - creature.position.y, target.position.x - creature.position.x)
	projectile.master = creature
	projectile.weapon_data = weapon_data
	var random_pitch = randf_range(0.6, 1.2)
	AudioManager.play_sound(shot_sound, creature.position, {"pitch_scale": random_pitch})
	add_object_to_world(projectile, creature)
	

extends Ability
class_name AbilityToss

@export var toss_force: float = 250.0
@export var stun_time: float = 2.0

func _init() -> void:
	ability_type = Type.ACTIVE
	
func activate(master: Entity) -> void:
	master.fix_inventory()
	if master.inventory.is_empty():
		return
		
	var tossed: Entity = master.inventory.pop_back()
	tossed.set_held_state(false)
	tossed.global_position = master.global_position + master.facing_direction * 16
	if tossed is Creature:
		tossed.add_to_stun_time(stun_time)
	
	if master.linear_velocity != Vector2.ZERO:
		tossed.apply_central_impulse(master.facing_direction * toss_force)
		tossed.physics_material_override.friction = 0.0
		
		var friction_tween = tossed.create_tween()
		friction_tween.tween_property(tossed.physics_material_override, "friction", 1.0, 1.0)
		friction_tween.play()
	else:
		pass

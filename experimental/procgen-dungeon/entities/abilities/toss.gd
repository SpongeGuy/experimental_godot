@tool
extends Ability
class_name AbilityToss

@export var toss_force: float = 250.0
@export var stun_time: float = 2.0
@export var tossed_invincibility_time: float = 0.5

func _init() -> void:
	ability_type = Type.ACTIVE
	cooldown = 1.0
	
func activate(master: Entity) -> bool:
	assert(master)
	master.fix_inventory()
	if master.inventory.is_empty():
		return false
		
	var tossed: PickupableEntity = master.inventory.pop_back()
	tossed.set_held_state(false)
	
	if tossed is Creature:
		tossed.add_to_stun_time(stun_time)
		tossed.go_invincible(tossed_invincibility_time)
		print(tossed._invincibility_timer)
		
	if master.linear_velocity != Vector2.ZERO or (master is Creature and master.controller_rs_input != Vector2.ZERO):
		tossed.apply_central_impulse(master.facing_direction * toss_force)
		tossed.global_position = master.global_position + master.facing_direction * 16
		
	else:
		tossed.global_position = master.global_position + Vector2(0, 8) # a slight offset so that whatever the guy is holding doesnt clips
	
	tossed.set_last_thrower(master)
	return true

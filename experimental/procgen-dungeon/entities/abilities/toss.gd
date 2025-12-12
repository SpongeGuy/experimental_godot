@tool
extends Ability
class_name AbilityToss

@export var toss_force: float = 550.0
@export var stun_time: float = 2.0
@export var tossed_invincibility_time: float = 0.5

func _init() -> void:
	ability_type = Type.ACTIVE
	cooldown = 0.1
	
func activate(master: Entity, direction: Vector2) -> bool:
	assert(master)
	if master.inventory.is_empty():
		return false
	
	var last_index = master.inventory.size() - 1
	var tossed: PickupableEntity = master.inventory[last_index]
	
	if not is_instance_valid(tossed):
		master.inventory.remove_at(last_index)
		return false
	
	var throw_velocity := Vector2.ZERO
	if master.linear_velocity != Vector2.ZERO or (master is Creature and master.controller_rs_input != Vector2.ZERO):
		throw_velocity = master.facing_direction * toss_force
		tossed.global_position = master.global_position + master.facing_direction * 16
	else:
		tossed.global_position = master.global_position + Vector2(0, 8)
	
	if tossed is Creature:
		tossed.add_to_stun_time(stun_time)
		tossed.go_invincible(tossed_invincibility_time)
	
	master.drop_item(last_index, throw_velocity)
	
	return true

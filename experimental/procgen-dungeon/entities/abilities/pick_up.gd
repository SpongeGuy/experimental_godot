extends Ability
class_name AbilityPickUp

func _init() -> void:
	ability_type = Type.ACTIVE
	
func activate(master: Entity) -> void:
	if master.inventory.size() >= master.inventory_size:
		return # inventory full
	
	var nearest: Entity = null
	var min_dist: float = INF
	for body in master.nearby_bodies:
		if body == master or not body.can_be_picked:
			continue
		var dist = master.global_position.distance_to(body.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = body
			
			
	if nearest:
		master.inventory.push_back(nearest)
		nearest.set_held_state(true, master)
		nearest.global_position = master.global_position + (master.hold_offset * (master.inventory.size()))

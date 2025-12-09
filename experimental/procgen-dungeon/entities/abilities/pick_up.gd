@tool
extends Ability
class_name AbilityPickUp

func _init() -> void:
	ability_type = Type.ACTIVE
	cooldown = 1.0
	
func activate(master: Entity) -> bool:
	assert(master)
	if master.inventory.size() >= master.inventory_size:
		return false # inventory full
	var nearest: PickupableEntity = null
	var min_dist: float = INF
	for body in master.nearby_bodies_in_interaction_area:
		if body == master or not body.can_be_picked or not body is PickupableEntity:
			continue
		var dist = master.global_position.distance_to(body.global_position)
		if dist < min_dist:
			min_dist = dist
			nearest = body
			
	if nearest:
		master.add_item_to_inventory(nearest)
		nearest.set_held_state(true)
		if nearest is Creature:
			nearest.nav_velocity = Vector2.ZERO
		return true
		
	return false

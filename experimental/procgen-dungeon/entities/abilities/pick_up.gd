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
		master.add_item_to_inventory(nearest)
		nearest.set_rigid_physics_active(true)
		nearest.set_held_state(true)
		if nearest is Creature:
			nearest.nav_velocity = Vector2.ZERO
		print(nearest.linear_velocity)
		

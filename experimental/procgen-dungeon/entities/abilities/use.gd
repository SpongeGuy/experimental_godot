@tool
extends Ability
class_name AbilityUse

func activate(master: Entity, direction: Vector2) -> bool:
	if not is_instance_valid(master):
		return false
	
	if not master.get("inventory"):
		return false
	
	var subject: PickupableEntity = master
	if subject.inventory.size() <= 0:
		return false
	
	if not is_instance_valid(subject.inventory[0]):
		return false
		
	return subject.inventory[0].activate(subject, direction)

extends PickupableEntity
class_name Item

func _ready() -> void:
	collision_layer = 1 << 4 # layer 5 = items
	collision_mask = (1 << 1) # terrain
	collision_mask |= (1 << 4) # other items
	collision_mask |= (1 << 2) # creatures collide and kick items around
	super._ready()

func activate(master: Entity) -> void:
	pass


extends Node
class_name HandComponent

var held_item: Node2D = null
@export var toss_force: float = 300.0
@export var held_item_offset: Vector2 = Vector2(24, 0)
@export var spit_force_multiplier: float = 2.5
@export var held_item_position: Marker2D
@export var eye_component: EyeComponent
@export var input_component: InputComponent

func _try_use_held_item(delta: float):
	if not held_item:
		return
	
	if not held_item.has_method("use"):
		return
		
	var using: bool = held_item.try_use(delta, self)
	held_item_position.position += Vector2(randf_range(-0.5, 0.5), randf_range(-0.5, 0.5))
	# input component needs to establish input behavior either eating or using

func _try_grab_from_storage() -> bool:
	if held_item != null:
		return false
	
	var closest_storage = eye_component.get_closest_storage()
	if closest_storage == null:
		return false
	
	if closest_storage.inventory.size() == 0:
		return false
	_take_from_storage(closest_storage)
	return true

func _take_from_storage(storage: Node2D) -> void:
	var item = storage.inventory.pop()
	held_item = item
	Item.freeze_item(item)
	
	item.reparent(held_item_position)
	item.position = Vector2.ZERO
	item.show()
	EventBus.item_taken_from_storage.emit(storage, item)

func _try_pickup() -> bool:
	if held_item != null:
		return false
	var closest_item = eye_component.get_closest_item()
	if closest_item == null:
		return false
	_pickup_item(closest_item)
	return true
	
var pickup_sound = preload("res://assets/sounds/effects/pickup.wav")
func _pickup_item(item: Node2D) -> void:
	held_item = item
	Item.freeze_item(item)
	item.reparent(held_item_position)
	item.position = Vector2.ZERO
	item.show()


func _try_toss_item() -> void:
	var item: RigidBody2D
	var item_was_spit: bool = false
	if held_item:
		item = held_item
		held_item = null
		
	if item == null:
		return
	
	_toss_item(item)

func _toss_item(item: RigidBody2D) -> void:
	item.reparent(get_parent())
	item.global_position = eye_component.sight_area.global_position + input_component.facing_direction * 16
	
	if Item.unfreeze_item(item):
		var spit_direction = input_component.facing_direction.normalized()
		item.apply_central_impulse(spit_direction * toss_force)
		item.apply_force_to_sprite(250)

	item.show()






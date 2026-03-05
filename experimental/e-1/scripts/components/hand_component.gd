extends Node
class_name HandComponent

@export var pickup_area: Area2D
@export var picked_location: Node2D
var item: CollisionObject2D
var lerp_weight: float = 20.0

func pick_up_item(body: CollisionObject2D) -> void:
	item = body
	
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("primary_action"):
		if not item:
			try_pick_up_item_in_area()
		else:
			let_go_of_item()
	
func try_pick_up_item_in_area() -> void:
	var bodies: Array = pickup_area.get_overlapping_bodies()
	var min_dist: float = INF
	var relevant_object: Node2D
	for body in bodies:
		if body == owner:
			continue
		var distance: float = body.global_position.distance_to(owner.global_position)
		if distance < min_dist:
			relevant_object = body
			min_dist = distance
	print(relevant_object)
	item = relevant_object
	
func let_go_of_item() -> void:
	item = null
	
func _physics_process(delta: float) -> void:
	if not item:
		return
	if picked_location:
		item.global_position = lerp(item.global_position, picked_location.global_position, delta * lerp_weight)
	else:
		print("shtieng")
		item.global_position = lerp(item.global_position, pickup_area.global_position, delta * lerp_weight)

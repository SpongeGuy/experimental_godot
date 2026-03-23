extends Component
class_name HandComponent

# ----------------------------------------------
# allows picking up and throwing items
# ----------------------------------------------



@export var pickup_area: Area2D
@export var picked_location: Node2D
@export var facing: FacingComponent
## the item is teleported a distance away from the entity so that it doesn't get stuck on its collidion box
@export var throw_tp_distance: float = 8

signal item_picked_up(item: Entity, by: Entity)

var item: Entity
var lerp_weight: float = 20.0

func _ready() -> void:
	EventBus.item_put_into_inventory.connect(_on_item_put_into_inventory)
	
	
#func _process(delta: float) -> void:
	#if Input.is_action_just_pressed("primary_action"):
		#if not item:
			#try_pick_up_item_in_area()
		#else:
			#var knockback: KnockbackComponent = item.get_component(KnockbackComponent)
			#if knockback and facing:
				#item.position += (facing.get_direction() * throw_tp_distance)
				#knockback.apply_knockback(facing.get_direction(), 250)
			#let_go_of_item()

func pick_up_item(body: Entity) -> void:
	if body is not Entity:
		return
	
	var body_pickupable: PickupableComponent = body.get_component(PickupableComponent)
	if not body_pickupable:
		return
	
	body_pickupable.toggle_held(entity)
	item = body
	item_picked_up.emit(item, entity)
	var ri: RecentlyInteracted = item.get_component(RecentlyInteracted)
	if ri:
		ri.interact(entity)
	

	
func try_pick_up_item_in_area() -> void:
	var bodies: Array = pickup_area.get_overlapping_bodies()
	var min_dist: float = INF
	var closest: Entity
	for body in bodies:
		if body == owner or body is not Entity:
			continue
		var distance: float = body.global_position.distance_to(entity.global_position)
		if distance < min_dist:
			closest = body
			min_dist = distance
	if closest:
		pick_up_item(closest)
	
# if the item that was held is put into an inventory, let go of it.
func _on_item_put_into_inventory(i: Entity) -> void:
	if item == i:
		let_go_of_item()
	
func let_go_of_item() -> void:
	if not item:
		return
	var pickupable: PickupableComponent = item.get_component(PickupableComponent)
	if pickupable:
		pickupable.toggle_held(entity)
	
	var ri: RecentlyInteracted = item.get_component(RecentlyInteracted)
	if ri:
		ri.interact(entity)
	
	item = null
	
	
	
func _physics_process(delta: float) -> void:
	if not item:
		return
	if picked_location:
		item.global_position = lerp(item.global_position, picked_location.global_position, delta * lerp_weight)
	else:
		item.global_position = lerp(item.global_position, pickup_area.global_position, delta * lerp_weight)

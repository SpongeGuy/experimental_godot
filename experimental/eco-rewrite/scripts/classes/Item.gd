extends RigidBody2D
class_name Item

@export var main_color: Color
@export var secondary_color: Color

@export var physics_collider: CollisionShape2D
@export var ability_component: AbilityComponent
@export var consumable_component: ConsumableComponent
@export var sprite_physics_component: SpritePhysicsComponent


enum Type{FOOD, TOOL, INERT}
@export var type: Type

static func freeze_item(item: Node2D) -> bool:
	var hurtbox: Hurtbox
	var cosmetic_collider: CosmeticCollider
	hurtbox = item.get_node_or_null("Hurtbox")
	cosmetic_collider = item.get_node_or_null("CosmeticCollider")
	
	if item is RigidBody2D:
		if hurtbox:
			hurtbox.process_mode = Node.PROCESS_MODE_DISABLED
		if cosmetic_collider:
			cosmetic_collider.process_mode = Node.PROCESS_MODE_DISABLED
		item.freeze = true
		item.physics_collider.disabled = true
		return true
	return false
		
static func unfreeze_item(item: Node2D) -> bool:
	var hurtbox: Hurtbox
	var cosmetic_collider: CosmeticCollider
	hurtbox = item.get_node_or_null("Hurtbox")
	cosmetic_collider = item.get_node_or_null("CosmeticCollider")
	
	if item is RigidBody2D:
		if hurtbox:
			hurtbox.process_mode = Node.PROCESS_MODE_INHERIT
		if cosmetic_collider:
			cosmetic_collider.process_mode = Node.PROCESS_MODE_INHERIT
		item.freeze = false
		item.physics_collider.disabled = false
		return true
	return false


func _ready() -> void:
	gravity_scale = 0.0
	collision_layer = (1 << 1)
	collision_mask = (1 << 0) | (1 << 1) | (1 << 2)
	
	lock_rotation = true
	
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	
	add_to_group("pickupable")


func try_use(delta: float, user: Node2D) -> void:
	if ability_component:
		return ability_component.try_use(delta, user)


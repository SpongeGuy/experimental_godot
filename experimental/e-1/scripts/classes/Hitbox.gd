extends Area2D
class_name Hitbox

@export var collision_shape: CollisionShape2D
@export var friends: FriendComponent
@export var collider_type: Array[ColliderType] = [ColliderType.NORMAL]

signal hit_received(damage_amount: float, source: Node2D)

enum ColliderType{NORMAL, FLYING, GROUND}

const COLLIDER_BITS = [7, 13, 15]

func _ready() -> void:
	if collider_type.is_empty():
		push_error("Collider type for hitbox cannot be empty!")
		
	for type in collider_type:
		collision_mask |= 1 << COLLIDER_BITS[type]
	#collision_layer = 1 << 6 # this is a hitbox
	area_entered.connect(_on_hurtbox_contact)

func _on_hurtbox_contact(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	if area.owner == owner:
		return
	if friends and friends.is_friend(area.owner):
		return
	hit_received.emit(area.damage, area.owner)




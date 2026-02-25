extends Area2D
class_name Hitbox

@export var collision_shape: CollisionShape2D

signal hit_received(damage_amount: float, source: Node2D)

func _ready() -> void:
	collision_layer = 1 << 8 # this is a hitbox
	collision_mask = 1 << 9 # look for hurtboxes
	area_entered.connect(_on_hurtbox_contact)


func _on_hurtbox_contact(area: Area2D) -> void:
	if area is not Hurtbox:
		return
	if area.owner == owner:
		return
	hit_received.emit(area.damage, area.owner)




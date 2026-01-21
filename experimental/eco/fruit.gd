extends RigidBody2D

@onready var physics_collider: CollisionShape2D = $CollisionShape2D

@onready var cosmetic_collider: Area2D = $CosmeticCollider
var sound = preload("res://assets/sounds/Pickup32.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("pickupable")
	cosmetic_collider.sound = sound








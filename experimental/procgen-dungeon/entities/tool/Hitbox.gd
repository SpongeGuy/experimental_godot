@tool

class_name Hitbox extends Area2D

@export var master: Entity
var collision_shape: CollisionShape2D

func _enter_tree() -> void:
	for child in get_children():
		if child is CollisionShape2D or ConvexPolygonShape2D or ConcavePolygonShape2D:
			return

	collision_shape = CollisionShape2D.new()
	add_child(collision_shape)
	collision_shape.name = "Shape"
	if Engine.is_editor_hint():
		collision_shape.owner = get_tree().edited_scene_root
	else:
		collision_shape.owner = owner

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D or ConvexPolygonShape2D or ConcavePolygonShape2D:
			collision_shape = child
	assert(master)
	collision_layer = 1 << 5 # this is a hitbox
	collision_mask = 1 << 6 # look for hurtboxes
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("Hitbox", self)

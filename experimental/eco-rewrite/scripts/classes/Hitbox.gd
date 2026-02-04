@tool

class_name Hitbox extends Area2D

@export var master: Node2D
@export var health_component: HealthComponent
var collision_shape: CollisionShape2D

signal hit_received(damage_amount: float, source: Node2D)

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
	collision_layer = 1 << 8 # this is a hitbox
	collision_mask = 1 << 9 # look for hurtboxes
	area_entered.connect(_on_hurtbox_entered)
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("Hitbox", self)

func _on_hurtbox_entered(area: Area2D) -> void:
	if area is Hurtbox:
		receive_damage(area)


func receive_damage(hurtbox: Hurtbox) -> void:
	if not health_component:
		return
		
	var damage_amount = hurtbox.base_damage
	var attacker = hurtbox.master
	
	health_component.take_damage(damage_amount, attacker)
	
	# for hit effects!
	hit_received.emit(damage_amount, attacker)

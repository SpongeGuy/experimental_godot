@tool
class_name KineticHurtbox extends Area2D


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
	
	collision_shape.disabled = true

func _ready() -> void:
	for child in get_children():
		if child is CollisionShape2D or ConvexPolygonShape2D or ConcavePolygonShape2D:
			collision_shape = child
	collision_layer = 1 << 6 # this is a hurtbox
	collision_mask = 1 << 5 # look for hitboxes (probably unnecessary)
	area_entered.connect(try_do_damage)
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("Hurtbox", self)
	

func try_do_damage(area: Area2D):
	if area is Hitbox and area.master != master and master._last_thrower != area.master:
		EventBus.try_change_creature_health.emit(area.master, -master._potential_kinetic_damage, master)
		

@tool
class_name DetectionArea extends Area2D

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
		collision_shape.owner = get_tree().edited_scene_rootfiles
	else:
		collision_shape.owner = owner
			
	collision_shape.modulate = Color(16.704, 53.848, 62.491, 1.0)

func _ready() -> void:
	collision_mask = (1 << 2) | (1 << 4) # look for creatures and fruit
	body_entered.connect(_on_enter_detection)
	body_exited.connect(_on_exit_detection)
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("DetectionArea", self)

# for organizing nearby nodes
func _on_enter_detection(body: Node2D) -> void:
	if body != master and body is Entity:
		master.nearby_bodies_in_detection_area.append(body)
	
func _on_exit_detection(body: Node2D) -> void:
	if body is Entity:
		master.nearby_bodies_in_detection_area.erase(body)

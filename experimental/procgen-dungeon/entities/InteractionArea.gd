@tool
class_name InteractionArea extends Area2D

@export var master: Entity

func _enter_tree() -> void:
	if not has_node("CollisionShape2D"):
		var collision_shape = CollisionShape2D.new()
		add_child(collision_shape)
		if Engine.is_editor_hint():
			collision_shape.owner = get_tree().edited_scene_root
		else:
			collision_shape.owner = owner

func _ready() -> void:
	collision_mask = (1 << 2) | (1 << 4) # look for creatures and fruit
	body_entered.connect(_on_enter_detection)
	body_exited.connect(_on_exit_detection)
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("InteractionArea", self)


# for organizing nearby nodes
func _on_enter_detection(body: Node2D) -> void:
	if body != master and body is Entity:
		master.nearby_bodies_in_interaction_area.append(body)
	
func _on_exit_detection(body: Node2D) -> void:
	if body is Entity:
		master.nearby_bodies_in_interaction_area.erase(body)

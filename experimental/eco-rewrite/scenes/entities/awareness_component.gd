extends Node2D


@export var awareness_area: Area2D
@export var master_origin: Node2D
@export var point_light: PointLight2D
@export var enabled: bool = false

var daytime: float

var visible_entities: Array = []

func _ready() -> void:
	awareness_area.body_entered.connect(body_entered_area)
	awareness_area.body_exited.connect(body_left_area)
	await get_tree().process_frame
	change_enabled(enabled)
			
	


func change_enabled(state: bool) -> void:
	# if enabled, only entities within radius are visible
	if not state:
		enabled = false
		for entity in WorldManager.world.entity_container.get_children():
			if entity is PhysicsBody2D:
				entity.show()
			
	elif state:
		enabled = true
		for entity in WorldManager.world.entity_container.get_children():
			if entity is RigidBody2D:
				entity.hide()
		for entity in visible_entities:
			entity.show()
	
func body_entered_area(body: Node2D) -> void:
	visible_entities.append(body)
	body.visible = true
	
func body_left_area(body: Node2D) -> void:
	visible_entities.erase(body)
	body.visible = false

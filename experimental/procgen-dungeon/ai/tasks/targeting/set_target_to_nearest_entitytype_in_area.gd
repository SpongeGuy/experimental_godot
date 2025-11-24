@tool
extends BTAction

@export var target_entity_class: String = "Creature"
@export var target_entity_type: String = ""
@export var area: StringName # this has to be a blackboard variable!!!

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Set target_entity to nearest [%s] [%s] in area %s" % [
		target_entity_class,
		target_entity_type,
		area,
	]

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")

func _tick(_delta: float) -> Status:
	assert(area, "Area must be set")
	
	var aggression_area: Area2D = blackboard.get_var(area)
	if not aggression_area:
		return FAILURE

	var valid_entities: Array = []

	for body in aggression_area.get_overlapping_bodies():
		if not is_instance_valid(body):
			continue
		if target_entity_type and body.entity_type:
			if target_entity_type == body.get("entity_type") and body != agent:
				valid_entities.append(body)
		elif target_entity_class and body.get("entity_class") and body != agent:
			if target_entity_class == body.entity_class:
				valid_entities.append(body)
		
	var closest_distance := 9999999.0
	var nearest_entity: Node2D = null
	for entity in valid_entities:
		
		var dist: float = agent.global_position.distance_to(entity.global_position)
		if dist < closest_distance:
			closest_distance = dist
			nearest_entity = entity
			

	if nearest_entity:
		blackboard.set_var("target_entity", nearest_entity)

		return SUCCESS
	
	return FAILURE

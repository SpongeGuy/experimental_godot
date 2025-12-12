@tool
extends BTAction

@export var blacklist: bool = false
@export var target_entity_class: Array[String] = []
@export var target_entity_type: Array[String] = ["Devil"]
@export var area: StringName # this has to be a blackboard variable!!!

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	var exception_string = ""
	if blacklist:
		exception_string = "anything except "
	if target_entity_class and target_entity_type:
		return "Set target_entity to %sleader %s %s in area [%s]" % [
			exception_string,
			target_entity_class,
			target_entity_type,
			area,
		]
	elif target_entity_class:
		return "Set target_entity to %sleader class %s in area [%s]" % [
			exception_string,
			target_entity_class,
			area,
		]
	elif target_entity_type:
		return "Set target_entity to %sleader type %s in area [%s]" % [
			exception_string,
			target_entity_type,
			area,
		]
	else:
		return "Set target_entity to %sleader %s %s in area [%s]" % [
			exception_string,
			target_entity_class,
			target_entity_type,
			area,
		]

func _enter() -> void:
	nav_agent = agent.get("nav_agent")

func _tick(_delta: float) -> Status:
	assert(area, "Area must be set")
	
	var target_area: Area2D = blackboard.get_var(area)
	if not target_area:
		return FAILURE

	var valid_entities: Array = []
	for body in target_area.get_overlapping_bodies():
		
		if not is_instance_valid(body) or body == agent:
			continue
			
		if not body.get("identification"):
			continue
		
		if not target_entity_type and not target_entity_class:
			if not blacklist:
				valid_entities.append(body)
			continue
		
		var passes_filter: bool = false
		
		if target_entity_type:
			var entity_type = body.identification.get("entity_type")
			if entity_type and entity_type in target_entity_type:
				passes_filter = true
				
		if target_entity_class:
			var entity_class = body.identification.get("entity_class")
			if entity_class and entity_class in target_entity_class:
				passes_filter = true
				
		var is_valid: bool = passes_filter if not blacklist else not passes_filter
		
		if is_valid:
			valid_entities.append(body)
			
		valid_entities.append(agent)
		
	# Only works for creatures with property leader_since
	var target_entity: Node2D = null
	var oldest_time: float

	for entity in valid_entities:
		if entity is Creature and entity.get("leader_since"):
			if not oldest_time:
				oldest_time = entity.leader_since
				target_entity = entity
				continue
		if oldest_time > entity.leader_since:
			oldest_time = entity.leader_since
			target_entity = entity
		
	if target_entity:
		if target_entity == agent:
			return FAILURE
		blackboard.set_var("target_entity", target_entity)
		return SUCCESS
	
	return FAILURE

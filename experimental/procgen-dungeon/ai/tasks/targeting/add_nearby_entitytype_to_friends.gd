@tool
extends BTAction

## Friends are not affected by this agent's attacks.

@export var blacklist: bool = false
@export var target_entity_class: Array[String] = ["Creature"]
@export var target_entity_type: Array[String] = []
@export var area: StringName # this has to be a blackboard variable!!!

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	var exception_string = ""
	if blacklist:
		exception_string = "anything except "
	if target_entity_class and target_entity_type:
		return "Add %snearest entities of %s %s in area %s to friends" % [
			exception_string,
			target_entity_class,
			target_entity_type,
			area,
		]
	elif target_entity_class:
		return "Add %snearest entities of class %s in area %s to friends" % [
			exception_string,
			target_entity_class,
			area,
		]
	elif target_entity_type:
		return "Add %snearest entities of type %s in area %s to friends" % [
			exception_string,
			target_entity_type,
			area,
		]
	else:
		return "Add %snearest entities of %s %s in area %s to friends" % [
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
		
		if body in agent.friends:
			continue
		
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
			agent.friends.append(body)
			

	return SUCCESS

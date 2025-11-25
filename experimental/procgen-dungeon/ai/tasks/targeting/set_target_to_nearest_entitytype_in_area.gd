## SetTargetNearestEntity
##
## This BTAction node scans a specified Area2D (retrieved from the blackboard) for overlapping
## bodies and identifies the nearest valid entity based on configurable class or type filters.
## Valid entities are those that match (or do not match, if blacklisted) the provided entity
## classes or types, excluding the agent itself and invalid instances.
##
## The action sets the blackboard variable "target_entity" to the nearest matching entity if
## one is found, returning SUCCESS. If no valid entity is found, it returns FAILURE.
##
## Key Features:
## - Supports filtering by entity class (e.g., ["Creature"]) or entity type (e.g., ["Enemy", "Ally"]).
## - Blacklist mode inverts the filter: entities are included if they do NOT match the provided classes/types.
## - Only one filter mode (class or type) is applied per body; type filter takes precedence if both are set.
## - Entities must have a "stats" node with "entity_class" or "entity_type" properties for filtering.
## - Distance is calculated using global positions.
## - Requires a valid Area2D blackboard variable specified in the 'area' export.
## - Retrieves a NavigationAgent2D from the agent in _enter(), though it is not used in the current implementation (potential for future pathfinding integration).
##
## Usage in Behavior Tree:
## - Use this action when the AI needs to dynamically select a target, such as the closest enemy or ally within a detection radius.
## - Ensure the blackboard has the Area2D set under the key specified in 'area'.
## - If multiple matching entities exist, only the nearest one is selected.
##
## Potential Improvements:
## - Avoid duplicate appendages in valid_entities by using a Set or checking for existence.
## - Integrate NavigationAgent2D for pathable distance checks instead of straight-line distance.
## - Handle cases where both class and type filters are set (currently, type overrides class via elif).
## - Add export for max distance threshold to limit target selection.

@tool
extends BTAction

@export var blacklist: bool = false
@export var target_entity_class: Array[String] = ["Creature"]
@export var target_entity_type: Array[String] = []
@export var area: StringName # this has to be a blackboard variable!!!

var nav_agent: NavigationAgent2D

func _generate_name() -> String:
	return "Set target_entity to nearest %s %s in area %s" % [
		target_entity_class,
		target_entity_type,
		area,
	]

func _enter() -> void:
	nav_agent = agent.get_node("NavigationAgent2D")

func _tick(_delta: float) -> Status:
	assert(area, "Area must be set")
	
	var target_area: Area2D = blackboard.get_var(area)
	if not target_area:
		return FAILURE

	var valid_entities: Array = []
	
	for body in target_area.get_overlapping_bodies():
		if not is_instance_valid(body) or body == agent:
			continue
		if target_entity_type and body.stats.entity_type:
			for etype in target_entity_type:
				if not blacklist:
					if etype == body.stats.get("entity_type") and body != agent:
						valid_entities.append(body)
				if blacklist:
					if etype != body.stats.get("entity_type") and body != agent:
						valid_entities.append(body)
		elif target_entity_class and body.stats.get("entity_class") and body != agent:
			for eclass in target_entity_class:
				if not blacklist:
					if eclass == body.stats.entity_class:
						valid_entities.append(body)
				if blacklist:
					if eclass != body.stats.entity_class:
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

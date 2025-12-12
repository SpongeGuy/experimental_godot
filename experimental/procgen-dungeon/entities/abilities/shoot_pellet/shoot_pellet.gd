@tool
extends Ability
class_name AbilityShootPellet

@export var pellet: PackedScene = preload("res://entities/projectiles/pellet.tscn")
@export var speed: float = 50

func _init() -> void:
	ability_type = Type.ACTIVE
	cooldown = 1

func activate(master: Entity, direction: Vector2) -> bool:
	var p = pellet.instantiate()
	var spawn_direction: Vector2 = master.facing_direction
	if spawn_direction == Vector2.ZERO:
		spawn_direction = direction.normalized()
	else:
		spawn_direction = spawn_direction.normalized()
		
	var spawn_offset: float = 24.0
	
	p.position = master.position + spawn_direction * spawn_offset
	p.velocity = direction * speed
	p.master = master
	EntityManager.add_entity_to_world(p)
	return true

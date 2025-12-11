@tool
extends Ability
class_name AbilityShootPellet

@export var pellet: PackedScene
@export var speed: float = 50

func _init() -> void:
	ability_type = Type.ACTIVE
	cooldown = 5

func activate(master: Entity, direction: Vector2) -> bool:
	var p = pellet.instantiate()
	p.position = master.position
	p.velocity = direction * speed
	p.master = master
	EntityManager.add_entity_to_world(p)
	return true

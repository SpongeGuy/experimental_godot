extends Ability
class_name AbilityShootPellet

@export var pellet: PackedScene
@export var speed: float = 50

func activate(master: Entity, direction: Vector2) -> bool:
	var p = pellet.instantiate()
	p.global_position = master.global_position
	p.velocity = direction * speed
	p.master = master
	master.get_parent().add_child(p)
	return true

@tool
extends Ability
class_name AbilityActivateHurtboxStatic

@export var duration: float = 0.2

func _init() -> void:
	ability_type = Type.ACTIVE
	cooldown = 2

func activate(master: Entity, direction: Vector2) -> bool:
	if not master.hurtbox:
		return false
	master.hurtbox.collision_shape.disabled = false
	await master.get_tree().create_timer(duration).timeout
	master.hurtbox.collision_shape.disabled = true
	
	return true

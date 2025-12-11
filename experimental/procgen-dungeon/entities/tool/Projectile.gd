@tool
extends Area2D
class_name Projectile

@export var velocity: Vector2 = Vector2.ZERO
@export var base_attack_damage: float = 0.0
var master: Entity

func _ready() -> void:
	collision_layer = 1 << 6 # this is a hurtbox
	collision_mask = 1 << 5 # look for hitboxes
	area_entered.connect(try_do_damage)
	
func try_do_damage(area: Area2D):
	if area is Hitbox and area is not Projectile and area.master != master:
		EventBus.try_change_creature_health.emit(area.master, -base_attack_damage, master)
		die()
		


func _process(delta: float) -> void:
	position += velocity * delta
	
	
func die() -> void:
	queue_free()

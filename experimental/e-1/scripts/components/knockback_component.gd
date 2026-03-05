# KnockbackComponent.gd
class_name KnockbackComponent
extends Node

@export var friction: float = 800.0
@export var bounce_factor: float = 0.3  # 0 = no bounce, 1 = full elastic
@export var min_bounce_speed: float = 50.0  # below this, stop bouncing

var knockback_velocity: Vector2 = Vector2.ZERO
var _body: CharacterBody2D

func _ready() -> void:
	_body = get_parent()

func _physics_process(delta: float) -> void:
	if knockback_velocity.is_zero_approx():
		return

	# apply knockback to the parent body's velocity
	_body.velocity += knockback_velocity

	# decay with friction
	var speed: float = knockback_velocity.length()
	var new_speed: float =  max(speed - friction * delta, 0.0)
	if new_speed > 0:
		knockback_velocity = knockback_velocity.normalized() * new_speed
	else:
		knockback_velocity = Vector2.ZERO

func apply_knockback(direction: Vector2, force: float) -> void:
	knockback_velocity += direction.normalized() * force

func apply_explosion_knockback(explosion_origin: Vector2, force: float, falloff: float = 1.0) -> void:
	var dir: Vector2 = (_body.global_position - explosion_origin).normalized()
	var dist: float = _body.global_position.distance_to(explosion_origin)
	var scaled_force: float = force / max(dist * falloff, 1.0)
	apply_knockback(dir, scaled_force)

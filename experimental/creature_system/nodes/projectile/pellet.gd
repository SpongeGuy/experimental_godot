extends Area2D

@export var velocity: Vector2 = Vector2(0,0)
var master: Creature

var weapon_data: WeaponResource

func _physics_process(delta: float) -> void:
	position += velocity * delta

func _on_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body != master:
		body._take_damage(master.weapon.weapon_data.base_damage, self)
		queue_free()

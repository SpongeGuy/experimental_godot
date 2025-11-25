class_name Hurtbox extends Area2D

@export var master: Creature

func _ready() -> void:
	area_entered.connect(try_do_damage)
	

func try_do_damage(area: Area2D):
	if area is Hitbox and area.master != master:
		EventBus.try_change_creature_health.emit(area.master, -master.stats.base_attack_damage, master)

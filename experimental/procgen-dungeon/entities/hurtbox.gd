class_name Hurtbox extends Area2D

@export var master: Entity

func _ready() -> void:
	collision_layer = 1 << 6 # this is a hurtbox
	collision_mask = 1 << 5 # look for hitboxes (probably unnecessary)
	area_entered.connect(try_do_damage)
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("Hurtbox", self)
	

func try_do_damage(area: Area2D):
	if area is Hitbox and area.master != master:
		EventBus.try_change_creature_health.emit(area.master, -master.stats.base_attack_damage, master)

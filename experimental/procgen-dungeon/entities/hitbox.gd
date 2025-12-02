class_name Hitbox extends Area2D

@export var master: Entity

func _ready() -> void:
	assert(master)
	collision_layer = 1 << 5 # this is a hitbox
	collision_mask = 1 << 6 # look for hurtboxes
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("Hitbox", self)

extends Node
class_name PlayerDebug

@export var master: PickupableEntity

func try_pick_up_ability() -> void:
	if master.abilities["ability_p"]:
		master.abilities["ability_p"].try_activate(master, master.facing_direction)
		
func try_toss_ability() -> void:
	if master.abilities["ability_t"]:
		master.abilities["ability_t"].try_activate(master, master.facing_direction)
		
func try_use_ability() -> void:
	if master.abilities["ability_u"]:
		master.abilities["ability_u"].try_activate(master, master.facing_direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pick_up"):
		try_pick_up_ability()
	elif event.is_action_pressed("toss"):
		try_toss_ability()
	elif event.is_action_pressed("use"):
		try_use_ability()

	

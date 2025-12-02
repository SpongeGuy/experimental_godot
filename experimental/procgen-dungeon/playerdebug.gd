extends Node

@export var master: Entity

func try_pick_up_ability() -> void:
	if master.abilities["ability_p"]:
		master.abilities["ability_p"].activate(master)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		try_pick_up_ability()

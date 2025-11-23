@tool
extends BTAction

@export var sound: Resource

func _generate_name() -> String:
	return "Play sound [%s]" % [
		sound,
	]

func _tick(_delta: float) -> Status:
	if sound:
		AudioManager.play_at_position(sound, agent.global_position)
	return SUCCESS

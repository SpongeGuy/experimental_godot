extends Node
class_name AbilityEffectsComponent

@export var master_origin: Node2D
@export var used_sound: AudioStream

func _on_ability_component_used() -> void:
	AudioManager.play_sound_with_random_pitch(used_sound, master_origin.global_position, 0.8, 1.2)

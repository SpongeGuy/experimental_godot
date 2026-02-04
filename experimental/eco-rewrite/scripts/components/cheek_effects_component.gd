extends Node
class_name CheekEffectsComponent

@export var cheek_component: CheekComponent
@export var spit_sound: AudioStream
@export var store_sound: AudioStream

func _on_cheek_component_item_spit(item: RigidBody2D) -> void:
	AudioManager.play_sound_at_position(spit_sound, cheek_component.master_origin.global_position)


func _on_cheek_component_item_stored(item: RigidBody2D) -> void:
	AudioManager.play_sound_at_position(store_sound, cheek_component.master_origin.global_position)

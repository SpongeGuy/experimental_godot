extends Node
class_name PassiveStorageEffectsComponent

@export var animation_player: AnimationPlayer
@export var item_stored_animation: String
@export var item_taken_animation: String
@export var put_sound: AudioStream
@export var take_sound: AudioStream
@export var master_origin: Node2D

func _item_stored(item: Node2D) -> void:
	AudioManager.play_sound_at_position(put_sound, master_origin.global_position)
	play_animation(item_stored_animation)
	
func _item_taken(item: Node2D) -> void:
	AudioManager.play_sound_at_position(take_sound, master_origin.global_position)
	play_animation(item_taken_animation)
	
func play_animation(animation_name: String) -> void:
	animation_player.stop()
	await get_tree().process_frame
	animation_player.play(animation_name)


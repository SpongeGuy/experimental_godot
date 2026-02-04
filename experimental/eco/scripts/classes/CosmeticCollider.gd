extends Area2D
class_name CosmeticCollider

var sounds: Array = [
	preload("res://assets/sounds/effects/thud.wav"),
	preload("res://assets/sounds/effects/thud2.wav"),
	]




func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if get_instance_id() < area.get_instance_id():
		return
	
	if area is CosmeticCollider and area != self:
		var sound = sounds.pick_random()
		AudioManager.play_sound_with_random_pitch(sound, global_position, 0.8, 1.2)

extends Area2D
class_name CosmeticCollider

var sound

func _ready() -> void:
	area_entered.connect(_on_area_entered)

func _on_area_entered(area: Area2D) -> void:
	if area is CosmeticCollider and area != self:
		AudioManager.play_at_position(sound, global_position)

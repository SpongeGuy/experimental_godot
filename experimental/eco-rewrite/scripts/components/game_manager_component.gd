extends Node
class_name GameManagerComponent

var timer_lengths: Dictionary = {
	"spring": 240,
	"summer": 300,
	"fall": 240,
	"winter": 180
}

var day_timer = timer_lengths["spring"]

func _process(delta: float) -> void:
	day_timer -= delta

func get_day_time_string() -> String:
	var minutes = floor(day_timer / 60)
	var seconds = int(floor(day_timer)) % 60
	var text = "%02d:%02d" % [minutes, seconds]
	return text

extends Component
class_name EdibleComponent

@export var stages: int = 1
@export var nutrition: float = 50.0

signal eaten()

func eat(power: int = 1) -> void:
	stages -= power
	if stages <= 0:
		eaten.emit()
		entity.queue_free()

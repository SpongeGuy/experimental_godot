extends Lobe
class_name TargetLobe

var target: Entity
var targeting: bool = true
@export var proximity: ProximityDetector

func _ready() -> void:
	proximity.detected.connect(_on_entity_detected)
	proximity.lost.connect(_on_entity_lost)
	
func _on_entity_detected(source: Entity, t: Entity) -> void:
	if targeting:
		print("yeas")
		target = t
		print(target)
		changed.emit()
	
func _on_entity_lost(source: Entity, t: Entity) -> void:
	if targeting:
		target = null
		changed.emit()

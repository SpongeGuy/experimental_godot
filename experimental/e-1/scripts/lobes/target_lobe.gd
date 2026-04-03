extends Lobe
class_name TargetLobe

var target: Entity
var targeting: bool = true
@export var proximity: ProximityDetector



func _ready() -> void:
	proximity.detected.connect(_on_entity_detected)
	proximity.lost.connect(_on_entity_lost)
	
	
func _process(delta: float) -> void:
	if Engine.get_process_frames() % 10 != 0:
		return
	
	if not target:
		return
		
	if not is_instance_valid(target):
		target = null
		changed.emit()
	
func _on_entity_detected(source: Entity, t: Entity) -> void:
	if targeting:
		target = t
		changed.emit()
	
func _on_entity_lost(source: Entity, t: Entity) -> void:
	if targeting:
		target = null
		changed.emit()

extends Component
class_name ProximityDetector

# --------------------------------------
# emits a signal when it detects a nearby entity
# with a valid script, defined in the inspector
# --------------------------------------

@export var area: Area2D

signal proximity_triggered(source: Entity, target: Entity)

@export var valid_components: Array[Script]

func _ready() -> void:
	area.collision_layer = 5
	area.collision_mask = 5
	area.area_entered.connect(_proximity_detected)
	
	
	
func _proximity_detected(other: Area2D) -> void:
	if other.owner is not Entity:
		return
	var subject: Entity = other.owner
	for component in valid_components:
		if subject.has_component(component):
			proximity_triggered.emit(entity, subject)
			return


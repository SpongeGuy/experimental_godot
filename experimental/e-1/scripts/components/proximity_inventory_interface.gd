extends Component
class_name ProximityInventoryInterface

@export var proximity: ProximityDetector
@export var inventory: Inventory

func _ready() -> void:
	proximity.proximity_triggered.connect(_on_proximity_triggered)
	
func _on_proximity_triggered(source: Entity, target: Entity) -> void:
	inventory.put_into_inventory(target)
	print(source, target)

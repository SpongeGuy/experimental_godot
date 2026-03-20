extends Component
class_name ProximityInventoryInterface

@export var proximity: ProximityDetector
@export var inventory: Inventory

func _ready() -> void:
	proximity.detected.connect(_on_detected)
	
func _on_detected(source: Entity, target: Entity) -> void:
	var give_points_to: Entity = RecentlyInteracted.resolve_attribution(target)
	var nutrition: NutritionComponent = target.get_component(NutritionComponent) as NutritionComponent
	if nutrition:
		var pi: PointsInterface = give_points_to.get_component(PointsInterface) as PointsInterface
		if pi:
			pi.add_nutri_points(nutrition.nutrition)
	inventory.put_into_inventory(target)


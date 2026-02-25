extends Ability
class_name EatAbility

func execute(user: Node2D, item: Node2D) -> void:
	# give nutrition to user
	# take away nutrition from item
	var item_consumable_component: ConsumableComponent = _get_consumable_component(item)
	var item_nutrition_component: NutritionComponent = _get_nutrition_component(item)
	var user_nutrition_component: NutritionComponent = _get_nutrition_component(user)
	var user_hunger_component: HungerComponent = _get_hunger_component(user)
	
	if item_nutrition_component and user_nutrition_component:
		var portions: int = 1
		if item_consumable_component:
			portions = item_consumable_component.total_stages
		var nutrition_transferred: float = item_nutrition_component.nutrition / (portions - item_consumable_component.current_stage)
		item_nutrition_component.lose_nutrition(nutrition_transferred)
		user_nutrition_component.gain_nutrition(nutrition_transferred)
		user_hunger_component.satiate_hunger(nutrition_transferred)

func _get_nutrition_component(node: Node2D) -> NutritionComponent:
	if node.has_node("NutritionComponent"):
		return node.get_node("NutritionComponent")
	return null

func _get_consumable_component(node: Node2D) -> ConsumableComponent:
	if node.has_node("ConsumableComponent"):
		return node.get_node("ConsumableComponent")
	return null

func _get_hunger_component(node: Node2D) -> HungerComponent:
	if node.has_node("HungerComponent"):
		return node.get_node("HungerComponent")
	return null

extends Node
class_name NutritionComponent

@export var nutrition: float

func gain_nutrition(amount: float) -> void:
	nutrition += amount
	
func lose_nutrition(amount: float) -> void:
	nutrition -= amount

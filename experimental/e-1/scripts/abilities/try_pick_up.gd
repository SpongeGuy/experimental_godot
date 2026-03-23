extends Ability
class_name AbilityTryPickUp

@export var hand_component: HandComponent

func execute() -> void:
	hand_component.try_pick_up_item_in_area()

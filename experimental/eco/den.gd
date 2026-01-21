extends Node2D
@onready var inventory: Inventory = $Inventory
@onready var accept_item_animation: AnimationPlayer = $AcceptItem

func _ready() -> void:
	EventBus.item_taken_from_storage.connect(_item_taken)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("pickupable"):
		inventory.push(body)
		inventory.freeze_item(body)
		accept_item_animation.stop()
		await get_tree().process_frame
		accept_item_animation.play("accept_item")
		
func _item_taken(storage: Node2D, item: Node2D) -> void:
	if storage == self:
		accept_item_animation.stop()
		await get_tree().process_frame
		accept_item_animation.play("accept_item")

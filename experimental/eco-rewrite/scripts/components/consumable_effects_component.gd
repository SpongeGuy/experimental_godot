extends Node
class_name ConsumableEffectsComponent

@export var consumable_component: ConsumableComponent
@export var master_origin: Node2D
@export var consume_type: Type

enum Type{DESTROY, DEACTIVATE}

signal deactivate

func _on_consumable_component_fully_consumed() -> void:
	match consume_type:
		Type.DESTROY:
			master_origin.queue_free()
		Type.DEACTIVATE:
			deactivate.emit()

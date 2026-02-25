extends Node2D


@onready var entity_container: Node2D = $Entities

func _ready() -> void:
	if entity_container:
		GameManager.entity_container = entity_container

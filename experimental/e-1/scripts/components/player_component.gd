extends Node
class_name PlayerComponent

func _ready() -> void:
	var body: CharacterBody2D = owner
	GameManager.register_player(body)


extends Node2D


@onready var sprite: Sprite2D = $Sprite2D

func _process(_delta: float) -> void:
	sprite.global_rotation = 0

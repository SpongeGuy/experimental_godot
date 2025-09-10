extends Node2D

@export var followee: Creature
@onready var viewport_size: Vector2 = get_viewport().get_visible_rect().size

@onready var player_ui: Control = $PlayerUI

func _process(delta: float) -> void:
	if followee:
		position = followee.position - (viewport_size / 2) + Vector2(5, 5)
	if player_ui.visible:
		player_ui.points_display.text = str(followee.points)

class_name World
extends Node2D

@onready var tilemap: TileMapLayer = $TileMapLayer
@onready var entity_container: Node2D = $Entities


func _ready() -> void:
	WorldManager.initialize(tilemap)
	EntityManager.entity_container = entity_container


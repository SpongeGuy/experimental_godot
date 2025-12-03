extends Node2D
class_name World

var tilemap_layer: TileMapLayer

func _init() -> void:
	tilemap_layer = $Terrain

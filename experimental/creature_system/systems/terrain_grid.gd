extends Node

var map = []
var width: int = 0
var height: int = 0

# 0 is impassable, 1 is passable without penalty

func initialize_map():
	map.resize(width)
	for x in range(width):
		map[x] = []
		map[x].resize(height)
		for y in range(height):
			map[x][y] = 1.0 # default to passable

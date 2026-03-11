extends Polygon2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rect = PackedVector2Array([
		Vector2(-200, -200),
		Vector2(200, -200),
		Vector2(200, 200),
		Vector2(-200, 200)
	])

	var hole = PackedVector2Array()
	var center = Vector2(0, 0)
	var radius = 30
	var points = 32
	for i in range(points):
		var angle = 2 * PI * i / points
		hole.append(center + Vector2(cos(angle), sin(angle)) * radius)
	if Geometry2D.is_polygon_clockwise(hole):
		hole.reverse()
	
	

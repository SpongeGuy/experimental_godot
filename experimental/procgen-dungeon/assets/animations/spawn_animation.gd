@tool
extends Node2D
class_name SpawnAnimation

@export var rect_size: Vector2 = Vector2(200.0, 150.0) : set = set_rect_size
@export var border_color: Color = Color.WHITE : set = set_border_color
@export var spawn_animation: AnimationPlayer

func _ready():
	queue_redraw()



func set_rect_size(new_size: Vector2):
	rect_size = new_size
	queue_redraw()

func set_border_color(new_color: Color):
	border_color = new_color
	queue_redraw()

func _draw():
	var half_size = rect_size * 0.5
	
	# Get full transform to screen pixels (includes node scale, camera zoom, canvas scale)
	var xform = get_global_transform_with_canvas()
	
	# Scale factors: screen pixels per local unit
	var scale_x = xform.x.length()
	var scale_y = xform.y.length()
	
	# Local thickness for exactly 1 screen pixel
	var thick_x = 1.0 / scale_x  # For left/right borders
	var thick_y = 1.0 / scale_y  # For top/bottom borders
	
	# Left border
	draw_rect(Rect2(
		Vector2(-half_size.x, -half_size.y),
		Vector2(thick_x, rect_size.y)
	), border_color)
	
	# Right border
	draw_rect(Rect2(
		Vector2(half_size.x - thick_x, -half_size.y),
		Vector2(thick_x, rect_size.y)
	), border_color)
	
	# Top border
	draw_rect(Rect2(
		Vector2(-half_size.x, -half_size.y),
		Vector2(rect_size.x, thick_y)
	), border_color)
	
	# Bottom border
	draw_rect(Rect2(
		Vector2(-half_size.x, half_size.y - thick_y),
		Vector2(rect_size.x, thick_y)
	), border_color)

extends Node2D

@export var fog_shape: Polygon2D

@export var max_clear_radius: float = 100.0

var fog_default_shape: PackedVector2Array = PackedVector2Array([
	Vector2(-1000, -1000),
	Vector2(-1000, 1000),
	Vector2(1000, 1000),
	Vector2(1000, -1000)
])

var fog_shader: Shader = preload("res://assets/shaders/fog.gdshader")

func _ready() -> void:
	fog_shape.polygon = fog_default_shape
	
	var mat = ShaderMaterial.new()
	mat.shader = fog_shader
	fog_shape.material = mat
	
	
func _physics_process(delta: float) -> void:
	var radius: float = max_clear_radius * (0.5 + 0.5 * sin(GameManager.time))
	fog_shape.material.set_shader_parameter("clear_radius", radius)
	fog_shape.material.set_shader_parameter("center_pos", get_viewport().get_canvas_transform() * fog_shape.global_position)

extends Node2D
class_name WeatherComponent

@export var fog_shape: Polygon2D
@export var fog_area: Area2D
@export var fog_collision_shape: CollisionShape2D
@export var weather_tint: CanvasModulate

var fog_color: Color = Color(0, 0, 0, 1)
var fog_position: Vector2 = Vector2.ZERO
var fog_radius: float = 100.0

var fog_default_shape: PackedVector2Array = PackedVector2Array([
	Vector2(-100000, -100000),
	Vector2(-100000, 100000),
	Vector2(100000, 100000),
	Vector2(100000, -100000)
])

var fog_shader: Shader = preload("res://assets/shaders/fog.gdshader")

func _ready() -> void:
	fog_shape.polygon = fog_default_shape
	
	var mat = ShaderMaterial.new()
	mat.shader = fog_shader
	fog_shape.material = mat
	fog_shape.material.set_shader_parameter("fog_color", fog_color)
	
func move_fog_instantly_to(pos: Vector2) -> void:
	fog_position = pos
	fog_area.global_position = pos
	fog_shape.material.set_shader_parameter("center_pos", fog_position)
	
	
func move_fog_to(pos: Vector2, delta: float) -> void:
	fog_position = lerp(fog_position, pos, delta)
	fog_area.global_position = lerp(fog_area.global_position, pos, delta)
	fog_shape.material.set_shader_parameter("center_pos", fog_position)
	

func change_fog_radius_to(radius: float, delta) -> void:
	fog_radius = lerp(fog_radius, radius, delta)
	fog_collision_shape.shape.radius = lerp(fog_collision_shape.shape.radius, radius * 0.6, delta)
	fog_shape.material.set_shader_parameter("clear_radius", radius)

	
var fog_pulse_maximum_radius: float = 100
var fog_pulse_minimum_radius: float = 20
var fog_pulse_frequency: float = 2

func set_fog_pulse_params(minimum: float, maximum: float, frequency: float) -> void:
	fog_pulse_maximum_radius = maximum
	fog_pulse_minimum_radius = minimum
	fog_pulse_frequency = frequency

func fog_pulse(delta: float) -> void:
	var f_radius: float = abs((fog_pulse_maximum_radius - fog_pulse_minimum_radius) * sin(fog_pulse_frequency * TimeManager.elapsed) + fog_pulse_maximum_radius + fog_pulse_minimum_radius)
	change_fog_radius_to(f_radius, delta)

func change_weather_tint_to(delta: float, color: Color) -> void:
	weather_tint.color = lerp(weather_tint.color, color, delta)

func change_fog_color_to(delta: float, color: Color) -> void:
	fog_color = lerp(fog_color, color, delta)
	fog_shape.material.set_shader_parameter("fog_color", fog_color)

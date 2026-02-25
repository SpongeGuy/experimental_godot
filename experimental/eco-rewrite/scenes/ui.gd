extends Node2D

@onready var health_box: HBoxContainer = $MainContainer/Container/Health/HBoxContainer
var health_elements: Array[Control] = []

var heart_sprite: Texture2D = preload("res://assets/textures/sprites/ui/icon-heart.png")
var heart_blank_sprite: Texture2D = preload("res://assets/textures/sprites/ui/icon-heart-blank.png")

@export var master_origin: Node2D
@export var camera: Camera2D
@export var game_manager_component: GameManagerComponent
var health_component: HealthComponent

@onready var timer_label: Label = $MainContainer/Timer/Label

func _ready() -> void:
	health_component = master_origin.get_node("HealthComponent")
	if not health_component:
		push_error("Health Component needed to render UI!")
		
	health_component.healed.connect(_try_update_health_ui)
	health_component.harmed.connect(_try_update_health_ui)
	update_health_ui()
	EventBus.creature_damaged.connect(_try_update_health_ui)
	
	
func _process(delta: float) -> void:
	update_health_sprite_scale(delta)
	update_day_timer()
	global_position = camera.position

	
	
	
	
var past_health: float = 0
	
func create_new_health_element(blank: bool = false) -> void:
	var element: Control = Control.new()
	var sprite: Sprite2D = Sprite2D.new()
	if blank:
		sprite.texture = heart_blank_sprite
	else:
		sprite.texture = heart_sprite
	sprite.offset = Vector2(-.5, .5)
	element.add_child(sprite)
	health_box.add_child(element)
	health_elements.append(element)
	
	
func _try_update_health_ui(amount: float, source: Node2D) -> void:
	update_health_ui()

func update_health_ui() -> void:
	if not health_component:
		return
	# maintain correct number of health
	if health_elements.size() < health_component.max_health:
		while health_elements.size() < health_component.max_health:
			create_new_health_element(true)
	elif health_elements.size() > health_component.max_health:
		var element = health_elements.pop_back()
		health_box.remove_child(element)
		element.queue_free()
		
	# now change the texture of the hearts depending
	for i in range(health_elements.size()):
		var sprite = health_elements[i].get_child(0)
		if i <= health_component.health - 1:
			if sprite.texture != heart_sprite:
				sprite.texture = heart_sprite
				sprite.scale = Vector2(2, 2)
		else:
			if sprite.texture != heart_blank_sprite:
				sprite.texture = heart_blank_sprite
				sprite.scale = Vector2(2, 2)
			
	past_health = health_component.health
		
func update_health_sprite_scale(delta: float) -> void:
	for element in health_elements:
		var sprite = element.get_child(0)
		sprite.scale = lerp(sprite.scale, Vector2.ONE, delta * 10)
		if abs(sprite.scale.x) - 1.0 < 0.1:
			sprite.scale = Vector2.ONE


func update_day_timer() -> void:
	timer_label.text = game_manager_component.get_day_time_string()

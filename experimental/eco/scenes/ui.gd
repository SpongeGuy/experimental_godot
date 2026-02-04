extends Node2D


@onready var health_box: HBoxContainer = $Container/Health/HBoxContainer
var health_elements: Array[Control] = []

var heart_sprite: Texture2D = preload("res://assets/textures/sprites/ui/icon-heart.png")
var heart_blank_sprite: Texture2D = preload("res://assets/textures/sprites/ui/icon-heart-blank.png")

func _ready() -> void:
	update_health_ui()
	EventBus.creature_damaged.connect(_try_update_health_ui)
	
func _process(delta: float) -> void:
	update_health_sprite_scale(delta)
	
	
	
	
	
	
var past_player_health: float = 0
	
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
	
	
func _try_update_health_ui(creature: Node2D, amount: float, source: Node2D) -> void:
	if creature == EntityManager.player_character:
		update_health_ui()

func update_health_ui() -> void:
	# get player health and max health.
	var player = EntityManager.player_character
	
	# maintain correct number of health
	if health_elements.size() < player.max_health:
		while health_elements.size() < player.max_health:
			create_new_health_element(true)
	elif health_elements.size() > player.max_health:
		var element = health_elements.pop_back()
		health_box.remove_child(element)
		element.queue_free()
		
	# now change the texture of the hearts depending
	for i in range(health_elements.size()):
		var sprite = health_elements[i].get_child(0)
		if i <= player.health - 1:
			if sprite.texture != heart_sprite:
				sprite.texture = heart_sprite
				sprite.scale = Vector2(2, 2)
		else:
			if sprite.texture != heart_blank_sprite:
				sprite.texture = heart_blank_sprite
				sprite.scale = Vector2(2, 2)
			
	past_player_health = player.health
		
func update_health_sprite_scale(delta: float) -> void:
	for element in health_elements:
		var sprite = element.get_child(0)
		sprite.scale = lerp(sprite.scale, Vector2.ONE, delta * 10)
		if abs(sprite.scale.x) - 1.0 < 0.1:
			sprite.scale = Vector2.ONE

extends Control

@export var death_label: Label

@export_group("Health Label")
@export var player_name_label: Label
@export var player_health_label: Label
@export var player_health_number: Label

@export_group("Hunger Label")
@export var player_hunger_label: Label
@export var player_hunger_number: Label

@export_group("Score Label")
@export var player_score_label: Label
@export var player_score_number: Label

@export_group("Health Bar")
@export var player_health_bar_node: Node2D
@export var player_health_bar: ProgressBar
@export var show_health_bar_timer_max: float = 1.0
@export var health_bar_animation: AnimationPlayer
var _show_health_bar_timer: float = 0.0

func _ready() -> void:
	EventBus.creature_damaged.connect(_handle_player_health_bar)
	player_health_bar.modulate = Color(255, 255, 255, 255)
	_show_health_bar_timer = 0.1

func _update_player_health_bar_visuals() -> void:
	player_health_bar.max_value = PlayerManager.player_instance.stats.max_health

func _process(delta: float) -> void:
	if PlayerManager.player_instance:
		player_health_label.visible = true
		player_health_number.visible = true
		player_health_number.text = str(PlayerManager.player_instance._health)
		player_hunger_number.text = str(round(PlayerManager.player_instance._hunger))
		player_score_number.text = str(PlayerManager.player_instance.score)
		
		player_name_label.text = str(PlayerManager.player_instance.identification.entity_type)
		
		_update_player_health_bar_visuals() # TODO: ADD A signal which detects when player instance has been changed
		
		if PlayerManager.player_instance: 
			death_label.visible = false 
		else: 
			death_label.visible = true
		
		var prev_timer: float = _show_health_bar_timer
		if _show_health_bar_timer > 0.0:
			_show_health_bar_timer = max(_show_health_bar_timer - delta, 0.0)
		
		if prev_timer > 0.0 and _show_health_bar_timer <= 0.0:
			health_bar_animation.play("health_bar_fade")
			
		if _show_health_bar_timer > 0.0 or health_bar_animation.is_playing():
			player_health_bar.global_position = PlayerManager.player_instance.global_position + Vector2(-(player_health_bar.size.x / 2), -15)
			player_health_bar.value = PlayerManager.player_instance._health
			
	else:
		player_health_label.visible = false
		player_health_number.visible = false
		player_name_label.visible = false

func _handle_player_health_bar(creature: Creature, amount: float, source: Node2D) -> void:
	if creature == PlayerManager.player_instance:
		_show_health_bar_timer = show_health_bar_timer_max
		player_health_bar.modulate = Color(255, 255, 255, 255)
		health_bar_animation.stop()

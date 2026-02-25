extends Node
class_name HealthEffectsComponents

@export var master_origin: Node2D
@export var main_sprite: Sprite2D
@export var input_component: InputComponent
@export var health_component: HealthComponent

@export var harmed_sound: AudioStream
@export var critically_harmed_sound: AudioStream

@export var invincibility_flash_enabled: bool = true

@export var die_animation_time: float = 2

func _ready() -> void:
	harmed_tween = get_tree().create_tween()
	
func _process(delta: float) -> void:
	do_invincibility_flashing(delta)
	
func die() -> void:
	if input_component:
		input_component.allow_input = false
	await get_tree().create_timer(die_animation_time).timeout
	master_origin.queue_free()

var harmed_tween: Tween
func play_harmed_effects(amount: float, attacker: Node2D) -> void:
	AudioManager.play_sound_with_random_pitch(harmed_sound, master_origin.global_position, 0.8, 1.2, 3)
	if harmed_tween:
		harmed_tween.kill()
	harmed_tween = create_tween()
	main_sprite.modulate = Color(1.0, 0.0, 0.0)
	harmed_tween.tween_property(main_sprite, "modulate", Color.WHITE, 0.25)
	
func do_invincibility_flashing(delta: float) -> void:
	if not invincibility_flash_enabled:
		return
		
	if not health_component or not main_sprite:
		return
		
	if health_component.invincible:
		main_sprite.modulate.a = 0.5 if int(Time.get_ticks_msec() / 10) % 2 == 0 else 1.0
	else:
		main_sprite.modulate.a = 1.0

class_name Grunt
extends Creature

# grunt exclusive things go here, but it's the simplest enemy type so probably not
#@onready var hurt_animation: AnimationPlayer = $Animations/HurtAnimation
var hurt_sound: AudioStream = preload("res://assets/sounds/grunt/grunt_hurt.mp3")
var eat_sound: AudioStream = preload("res://assets/sounds/grunt/grunt_bite.mp3")



func _ready() -> void:
	stat_sheet = preload("res://entities/creatures/herbivores/grunt/grunt_sheet.tres")
	EventBus.creature_satiated_hunger.connect(_make_eat_sound)
	super._ready()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _health <= 0:
		queue_free()

func take_damage(amount: float, attacker: Node2D) -> bool:
	if super.take_damage(amount, attacker):
		AudioManager.play_at_position(hurt_sound, global_position)
		return true
	return false
	

func _make_eat_sound(creature: Creature, amount: float) -> void:
	if creature == self:
		AudioManager.play_at_position(eat_sound, position)

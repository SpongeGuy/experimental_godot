class_name Growl
extends Creature

# grunt exclusive things go here, but it's the simplest enemy type so probably not
@onready var aggravation: Area2D = $Areas/Aggravation
@onready var hurt_animation: AnimationPlayer = $Animations/HurtAnimation
var hurt_sound: AudioStream = preload("res://assets/sounds/grunt/grunt_hurt.mp3")

func _ready() -> void:
	bt_player.blackboard.set_var("aggravation", aggravation)
		
	aggravation.collision_layer = 1 << 2
	aggravation.collision_mask = 1 << 2
		
	super._ready()
	
func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	if _health <= 0:
		queue_free()

func take_damage(amount: int, attacker: Node2D):
	super.take_damage(amount, attacker)
	hurt_animation.play("hurt")
	#AudioManager.play_at_position(hurt_sound, position)

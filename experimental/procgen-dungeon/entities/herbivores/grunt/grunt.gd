class_name Grunt
extends Creature

# grunt exclusive things go here, but it's the simplest enemy type so probably not
@onready var sight_area: Area2D = $Areas/Sight
@onready var hurt_animation: AnimationPlayer = $Animations/HurtAnimation
var hurt_sound: AudioStream = preload("res://assets/sounds/grunt/grunt_hurt.mp3")
var grunt_stat_sheet: CreatureStats = preload("res://entities/herbivores/grunt/grunt_stats.tres")

var nearby_bodies: Array[Node2D] = []

func _ready() -> void:
	
	if sight_area:
		sight_area.collision_mask = (1 << 2) | (1 << 4) # creatures and fruit
		sight_area.body_entered.connect(_on_enter_sight_area)
		sight_area.body_exited.connect(_on_exit_sight_area)
	super._ready()
	
func _physics_process(delta: float) -> void:
	if _health <= 0:
		queue_free()

func take_damage(amount: int, attacker: Node2D):
	print("grunt")
	super.take_damage(amount, attacker)
	hurt_animation.play("hurt")
	AudioManager.play_at_position(hurt_sound, position)
	

# for organizing nearby nodes
func _on_enter_sight_area(body: Node2D) -> void:
	if body != self:
		nearby_bodies.append(body)
	
func _on_exit_sight_area(body: Node2D) -> void:
	nearby_bodies.erase(body)

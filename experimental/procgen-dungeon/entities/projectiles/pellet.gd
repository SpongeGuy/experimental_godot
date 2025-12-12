extends Projectile

@onready var blink_animation: AnimationPlayer = $Graphical/Blink

var death_timer: float = 25.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	blink_animation.play("blink")

func _process(delta: float) -> void:
	super._process(delta)
	death_timer = max(death_timer - delta, 0.0)
	if death_timer <= 0.0:
		die()

@tool
extends Projectile

@onready var blink_animation: AnimationPlayer = $Graphical/Blink

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	blink_animation.play("blink")



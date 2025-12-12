extends Item

@onready var shine_animation: AnimationPlayer = $Node/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shine_animation.play("shine")
	
	super._ready()


func activate(master: Entity, direction: Vector2) -> bool:
	queue_free()
	return super.activate(master, direction)
	

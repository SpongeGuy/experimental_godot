extends Item


var main_color: Color = Color("222034")

@onready var hurtbox: Hurtbox = $Hurtbox

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	add_to_group("pickupable")
	hurtbox.collision_shape.disabled = false

func _process(delta: float) -> void:
	update_sprite_forces(delta)
	rotate_sprite(delta)

func rotate_sprite(delta: float) -> void:
	main_sprite.rotation_degrees += (5 * linear_velocity.x * delta)

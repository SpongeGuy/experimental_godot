extends Item
class_name Fruit

var main_color: Color = Color("ff4a4a")

@onready var sprite: Sprite2D = $Sprites/ScaleController/MainSprite

@export var consumed_stage: int = 0
@export var nutrition: float = 5.0
var nutrition_part: float

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super._ready()
	add_to_group("pickupable")
	
	sprite.frame = consumed_stage
	
	nutrition_part = nutrition / sprite.hframes

func _process(delta: float) -> void:
	update_sprite_forces(delta)

func use(user: Creature) -> void:
	user.satiate_hunger(nutrition_part)
	nutrition = nutrition - nutrition_part
	change_consumed_stage(consumed_stage + 1)
	if consumed_stage >= sprite.hframes:
		queue_free()
		
func change_consumed_stage(stage: int) -> void:
	var frame = clamp(stage, 0, sprite.hframes - 1)
	consumed_stage = stage
	sprite.frame = frame



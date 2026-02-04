extends Node2D

@onready var l1: Label = $Control/VBoxContainer/Label
@onready var l2: Label = $Control/VBoxContainer/Label2
@onready var l3: Label = $Control/VBoxContainer/Label3
@onready var l4: Label = $Control/VBoxContainer/Label4

@onready var sprite = preload("res://assets/textures/sprites/ui/sprite_big.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(sprite)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position = get_global_mouse_position()
	display_debug_text()
	
		
func display_debug_text() -> void:
	var cell: Cell = WorldManager.get_cell(position)
	l1.text = str(position)
	l2.text = str(WorldManager.world_to_chunk(position))
	l3.text = str(WorldManager.world_to_local(position))
	if cell:
		l4.text = str("n:",cell.nutrition)
	else:
		l4.text = str("none")


extends Control

var selected_creep_node: CreepNode
var reticle_sprite: Sprite2D

@onready var pos_l := $VBoxContainer/pos
@onready var nutrition_l := $VBoxContainer/nutrition
@onready var age_l := $VBoxContainer/age
@onready var aggression_l := $VBoxContainer/aggression
@onready var last_spread_l := $VBoxContainer/last_spread
@onready var flags_l := $VBoxContainer/flags
@onready var growth_l := $VBoxContainer/growth
@onready var creeplvl_l := $VBoxContainer/creeplvl
@onready var bhavior_l := $VBoxContainer/bhavior

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reticle_sprite = $Sprite2D

func _update_creep_node_info() -> void:
	if not selected_creep_node:
		return
		
	pos_l.text = str(selected_creep_node.cell_position)
	nutrition_l.text = str("n: ", selected_creep_node.nutrition)
	age_l.text = str("age: ", selected_creep_node.age)
	aggression_l.text = str("aggr: ", selected_creep_node.colony.aggression)
	last_spread_l.text = str("spread: ", selected_creep_node.spread_attempt_timer)
	flags_l.text = ""
	for flag in selected_creep_node.debug_flags:
		flags_l.text += str("{", flag, ": ", selected_creep_node.debug_flags[flag], "}\n")
	growth_l.text = str("g: ", selected_creep_node.growth_progress)
	creeplvl_l.text = str("clvl: ", WorldManager.get_cell(selected_creep_node.cell_position).creep_level)
	bhavior_l.text = str("bhavior: ", selected_creep_node.behavior_timer)


func _process(delta: float) -> void:
	_update_creep_node_info()

func _input(event):
	if event is InputEventMouseButton and event.pressed:
		var space_state = get_world_2d().direct_space_state
		
		# Create a small circle shape for the query
		var query = PhysicsShapeQueryParameters2D.new()
		var shape = CircleShape2D.new()
		var mouse_pos = get_global_mouse_position()
		shape.radius = 1.0  # Small radius, adjust if needed
		query.shape = shape
		query.transform = Transform2D(0, mouse_pos)

		# Set to interact with ALL layers
		query.collision_mask = 0xFFFFFFFF
		query.collide_with_areas = true
		query.collide_with_bodies = true
		
		var results = space_state.intersect_shape(query)
		
		for result in results:
			if result.collider.get_parent() is CreepNode:
				selected_creep_node = result.collider.get_parent()
				reticle_sprite.position = selected_creep_node.position
			

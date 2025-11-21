extends CharacterBody2D
class_name Creature

# ------------------------------------------------------------------------
# CORE STATS
# ------------------------------------------------------------------------
@export_category("Stats")
@export var max_health: int = 5
@export var max_hunger: float = 1000
@export var hunger_rate: float = 4.0 # per second while moving
@export var base_speed: float = 120.0
@export var debug_name: String = ""

# ------------------------------------------------------------------------
# MOVEMENT AND COLLISION FLAGS
# ------------------------------------------------------------------------
@export_category("Movement & Collision")
@export var avoidance_radius: float = 32.0

@export var collide_with_terrain: bool = true
@export var solid_to_creatures: bool = true
@export var use_rvo_avoidance: bool = true

@export var use_pathfinding: bool = true # false -> straight-line movement (ghosts, flyers, etc)

# ------------------------------------------------------------------------
# PLAYER CONTROL
# ------------------------------------------------------------------------
@export_category("Player Possession")
@export var accept_player_input: bool = false
# ------------------------------------------------------------------------
# INTERNAL STATE
# ------------------------------------------------------------------------
var health: int = max_health
var hunger: float = 0.0

var _straight_line_target: Vector2 = Vector2.INF # used only when use_pathfinding = false

@onready var debug_label: Label = $Label

@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
@onready var bt_player: BTPlayer = $BTPlayer
@onready var sight_area: Area2D = $SightArea
@onready var interaction_area: Area2D = $InteractionArea

var nearby_bodies: Array[Node2D] = []

func _ready() -> void:
	nav_agent.velocity_computed.connect(_on_velocity_computed)
	nav_agent.avoidance_enabled = use_rvo_avoidance
	nav_agent.radius = avoidance_radius
	nav_agent.neighbor_distance = avoidance_radius * 3.0
	nav_agent.max_neighbors = 12
	nav_agent.time_horizon_agents = 1.8
	nav_agent.time_horizon_obstacles = 1.2
	
	collision_layer = 1 << 2 # layer 3 = creatures (layer numbers starting from 0)
	collision_mask = 1 << 1 # layer 2 = terrain / walls
	
	if collide_with_terrain == false:
		collision_mask &= ~(1 << 1)
		
	if solid_to_creatures:
		collision_mask |= (1 << 2) # collide with other creatures
		
	if sight_area:
		sight_area.collision_mask = (1 << 2) | (1 << 4)
		sight_area.body_entered.connect(_on_enter_sight_area)
		sight_area.body_exited.connect(_on_exit_sight_area)

func _physics_process(delta: float) -> void:
	update_hunger(delta)
	update_movement(delta)
	
	
func update_hunger(delta: float) -> void:
	hunger = min(hunger + hunger_rate * delta, max_hunger)
	bt_player.blackboard.set_var("hunger", hunger)
		

	
		
func update_movement(_delta: float) -> void:
	var intended_velocity: Vector2 = Vector2.ZERO
	
	# ------------------------------------------------------------------------
	# 1. player manual override (highest priority)
	# ------------------------------------------------------------------------
	if accept_player_input:
		var input_dir: Vector2 = Input.get_vector("move_west", "move_east", "move_north", "move_south")
		if input_dir.length() > 0.1:
			intended_velocity = input_dir.normalized() * base_speed
			# player is moving -> we ignore BT movement this frame
			# (but BT can still run actions like bite/shoot/explode)
		# if no input, intended_velocity stays ZERO -> BT gets full control below
		
	# ------------------------------------------------------------------------
	# 2. behavior tree movement (only if player isn't overriding)
	# ------------------------------------------------------------------------
	if intended_velocity == Vector2.ZERO and bt_player.active:
		if use_pathfinding:
			if not nav_agent.is_navigation_finished():
				var next := nav_agent.get_next_path_position()
				intended_velocity = global_position.direction_to(next) * base_speed
		else:
			if _straight_line_target != Vector2.INF:
				if global_position.distance_to(_straight_line_target) < 20.0:
					_straight_line_target = Vector2.INF
				else:
					intended_velocity = global_position.direction_to(_straight_line_target) * base_speed
					
	# ------------------------------------------------------------------------
	# 3. apply velocity (with or without avoidance)
	# ------------------------------------------------------------------------
	if use_rvo_avoidance:
		nav_agent.set_velocity(intended_velocity)
	else:
		velocity = intended_velocity
		#move_and_slide()

func _on_velocity_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity
	#move_and_slide()
	
func move(p_velocity: Vector2, _factor: float = 0.2) -> void:
	#velocity = lerp(velocity, p_velocity, factor)
	velocity = p_velocity
	move_and_slide()

# ------------------------------------------------------------------------
# public API for BTAction nodes (called from custom tasks)
# ------------------------------------------------------------------------

func bt_set_target_position(pos: Vector2) -> void:
	if use_pathfinding:
		nav_agent.target_position = pos
	else:
		_straight_line_target = pos
		
func bt_set_target_entity(entity: Node2D) -> void:
	if entity and is_instance_valid(entity):
		bt_set_target_position(entity.global_position)
		
func bt_stop_movement() -> void:
	if use_pathfinding:
		nav_agent.target_position = global_position # instantly finishes path
	else:
		_straight_line_target = Vector2.INF
		
func bt_face_towards(pos: Vector2) -> void:
	if (pos.x - global_position.x) > 0:
		scale.x = abs(scale.x)
	else:
		scale.x = -abs(scale.x)

func bt_eat_fruit(fruit: Node) -> void:
	hunger = max(hunger - 70.0, 0.0)
	if fruit.has_method("eat"):
		fruit.eat()
	else:
		fruit.queue_free()
		
func bt_bite(target: Creature) -> void:
	var damage: int = 1
	target.take_damage(damage)
	
func bt_die() -> void:
	die()
	
# ------------------------------------------------------------------------
# private helpers
# ------------------------------------------------------------------------
#func get_bodies_in_radius(center: Vector2, radius: float, exclude: Array = []) -> Array:
	#var space_state = get_world_2d().direct_space_state
	#
	#var query = PhysicsShapeQueryParameters2D.new()
	#var circle_shape = CircleShape2D.new()
	#circle_shape.radius = radius
	#query.shape = circle_shape
	#query.transform = Transform2D(0, center)
	#query.collision_mask = (1 << 2) | (1 << 4) # query creatures and fruits
	#query.exclude = exclude
	#
	## Set to true if you only want bodies that have their collision shape fully inside the radius
	## query.set_shape_as_trigger(false)  # default is false
	#
	#return space_state.intersect_shape(query, 32)  # 32 = max results (increase if needed)
	

# for organizing nearby nodes
func _on_enter_sight_area(body: Node2D) -> void:
	if body != self:
		nearby_bodies.append(body)
	
func _on_exit_sight_area(body: Node2D) -> void:
	nearby_bodies.erase(body)
	

func set_health(value: int) -> void:
	health = clamp(value, 0, max_health)
	if health <= 0:
		die()
		
func set_hunger(value: float) -> void:
	hunger = clampf(value, 0.0, max_hunger)
	
func satiate_hunger(value: float) -> void:
	hunger = max(hunger - value, 0.0)

func take_damage(amount: int) -> void:
	health -= amount
	if health <= 0:
		die()
		
func die() -> void:
	bt_player.set_active(false)
	queue_free()

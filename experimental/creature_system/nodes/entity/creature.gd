class_name Creature extends CharacterBody2D

@export var creature_stats: CreatureResource
@export var weapon: Weapon
@onready var root: Node2D = $Root
@export var points: int = 0

var animation_player: AnimationPlayer

@export var hitboxes: Array[CollisionShape2D]

# for player control
@export var under_player_control: bool = false
@onready var mouse_target: Node2D

var _is_dead: bool = false
var _moved_this_frame: bool = false

# used to add to final normal velocity
# apply external forces like knockback from explosions to this, then add to `velocity`
var _forces: Vector2

func _ready() -> void:
	print("children of: ", get_children())

func _process(delta: float):
	if !mouse_target and under_player_control:
		mouse_target = Node2D.new()
		add_child(mouse_target)
	if under_player_control:
		_player_attack(delta)

func _physics_process(delta: float) -> void:
	if under_player_control:
		_player_control(delta)
	_post_physics_process(delta)

func _post_physics_process(delta: float) -> void:
	if not _moved_this_frame:
		velocity = lerp(velocity, Vector2.ZERO, 0.2)
	_moved_this_frame = false
	
	
# change target instantaneously based on encoded priorities
func _prioritize_target(nearby: Array) -> Node2D:
	for node in nearby:
		if node.is_in_group("fruit") and is_in_group("herbivore"):
			return node
		if node.is_in_group("player") and is_in_group("evil"):
			return node
	return nearby[0] if nearby.size() > 0 else null

func add_object_to_world(object: Node2D, creature: Creature):
	var world = get_tree().get_first_node_in_group("world")
	if world:
		world.add_child(object)
	else:
		push_error("No node in group 'world' found! Falling back to creature's parent.")
		creature.get_parent().add_child(object)

func _take_damage(amount: float, origin: Node2D):
	# reset rig swell and deflate animation here
	animation_player.seek(0, true)
	animation_player.play(&"rig_swell_and_deflate")
	var text_particle: Node2D = preload("res://nodes/effects/text_particle.tscn").instantiate()
	text_particle.create(str(origin.weapon_data.base_damage), position)
	add_object_to_world(text_particle, self)
	if _is_dead:
		return
	creature_stats.health -= amount
	
	if creature_stats.health <= 0.0:
		die(origin)

# play animations, award points, steal stats, whatever
func death_effects(killer: Creature) -> void:
	killer.points += creature_stats.point_value
	
func move(p_velocity: Vector2, factor: float = 0.2) -> void:
	velocity = lerp(velocity, p_velocity, factor)
	_moved_this_frame = true
	move_and_slide()
	

# handle everything related to the self when dying
func die(origin: Node2D) -> void:
	_is_dead = true
	root.process_mode = Node.PROCESS_MODE_DISABLED
	if origin.master:
		death_effects(origin.master)
	queue_free()
	
# probably should be a part of a player node that extends creature
# aiiieee!!!
func _player_control(delta: float) -> void:
	var input_direction = Input.get_vector("left_input", "right_input", "up_input", "down_input")
	if input_direction.length() >= 1:
		input_direction = input_direction.normalized()
	velocity = input_direction * creature_stats.movement_speed * delta
	move_and_slide()
	
func _player_attack(delta: float) -> void:
	mouse_target.position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		weapon.activate(mouse_target)

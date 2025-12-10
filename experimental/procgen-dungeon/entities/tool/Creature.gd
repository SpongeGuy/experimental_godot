extends PickupableEntity
class_name Creature

# ------------------------------------------------------------------------
# CORE STATS
# ------------------------------------------------------------------------
@export var stat_sheet: CreatureStats

# ------------------------------------------------------------------------
# INTERNAL STATE
# ------------------------------------------------------------------------
## Defines location goals (Vector2) for entities to pathfind towards.
## There are two types: long and short. Long should be used for long-term goals in case a creature wants to
## travel to a specific location over a long period of time. Short should be used for immediate actions like
## collecting an item or fruit.
@export var goals: Dictionary[String, Vector2] = {
	"long": Vector2.INF,
	"short": Vector2.INF,
}


## Flag to override the creature's health with a custom value.
@export_group("Health")
@export var overriding_health: bool = false
@export var health_override: float = 0
@export_group("Hunger")
@export var overriding_hunger: bool = false
@export var hunger_override: float = 0
@export_group("Invincibility")
@export var can_go_invincible: bool = true
@export var invincibility_time: float = 2
var _stun_time: float = 0.0 # later on implement stunning based on this value.
var _health: float
var _hunger: float
var stats: CreatureStats
var _invincibility_timer: float = 0
var controller_rs_input: Vector2

func set_bt_player_active(active: bool) -> void:
	if active == true:
		if bt_player and _stun_time <= 0:
			bt_player.active = true
	else:
		if bt_player:
			bt_player.active = false

func add_to_stun_time(stun_time: float) -> void:
	_stun_time += stun_time
	if _stun_time >= 0:
		graphical_module.scale.y = -1
		set_bt_player_active(false)
		set_rigid_physics_active(true)

func update_stun(delta: float) -> void:
	if _stun_time <= 0:
		return
	if not is_held:
		_stun_time = max(_stun_time - delta, 0)
	if _stun_time <= 0 and not is_held:
		graphical_module.scale.y = 1
		set_rigid_physics_active(false)
		set_bt_player_active(true)
		
func set_rigid_physics_active(active: bool) -> void:
	if active:
		# for creatures, this makes them a physics object (able to be knocked around by external impulses)
		freeze = false
		set_bt_player_active(false)
	else:
		# returns the creature back to kinematic behavior mode
		freeze = true
		set_bt_player_active(true)
		linear_velocity = Vector2.ZERO




# use this velocity for pathfinding, all velocities will be added 
# together on every frame and set to this unit's velocity.
# move_and_slide() should never be called directly in this script
## Velocity used for navigation and pathfinding; combined with other velocities each frame.
var nav_velocity: Vector2 = Vector2.ZERO

## This is what is used with move_and_collide(). All of the velocities are added up to this number.
var total_velocity: Vector2 = Vector2.ZERO

# add onto this velocity for temporary effects like knockback
# this variable constantly lerps back to 0
## Temporary velocity for effects like knockback; lerps back to zero over time.
var effect_velocity: Vector2 = Vector2.ZERO
## Decay factor for effect_velocity lerp back to zero.
@export var effect_velocity_decay_factor = 5
## Reference to the NavigationAgent2D node for pathfinding.
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D

# ------------------------------------------------------------------------
# MOVEMENT AND COLLISION FLAGS
# ------------------------------------------------------------------------
@export_group("Movement & Collision")
@export var avoidance_radius: float = 32.0

@export var collide_with_terrain: bool = true
@export var solid_to_creatures: bool = true
@export var use_rvo_avoidance: bool = true

@export var use_pathfinding: bool = true # false -> straight-line movement (ghosts, flyers, etc)
@export var aim_direction: Vector2 = Vector2.ZERO

# ------------------------------------------------------------------------
# PLAYER CONTROL
# ------------------------------------------------------------------------
@export_group("Player Possession")
@export var accept_player_input: bool = false
var reticle: Node2D

## Initializes the creature's statistics, duplicating the stat sheet and setting initial health and hunger.
func _ready_statistics() -> void:
	stats = stat_sheet.duplicate()
	assert(stats)
	
	if overriding_health:
		_health = health_override
	else:
		_health = stats.max_health
		
	if overriding_hunger:
		_hunger = hunger_override
	else:
		_hunger = 0.0
	
func _ready_reticle() -> void:
	var reticle_scene = preload("res://systems/reticle/reticle.tscn")
	if accept_player_input:
		reticle = reticle_scene.instantiate()
		add_child(reticle)
		

func _ready() -> void:
	_ready_statistics()
	_ready_reticle()
	set_rigid_physics_active(false)
	
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

	EventBus.try_change_creature_health.connect(_on_change_health)
	EventBus.try_change_creature_hunger.connect(_on_change_hunger)
	
	super._ready()
	
func _setup_physics_properties() -> void:
	if bt_player:
		if freeze:
			bt_player.active = true
		else:
			bt_player.active = false
	super._setup_physics_properties()
	

func _process(delta: float) -> void:
	super._process(delta)
	if can_go_invincible:
		_invincibility_timer = max(_invincibility_timer - delta, 0)

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	update_hunger(delta)
	update_movement(delta)
	update_stun(delta)
	update_facing_direction(delta)
	
## Increases hunger over time and updates the behavior tree blackboard.
func update_hunger(delta: float) -> void:
	_hunger = min(_hunger + stats.hunger_rate * delta, stats.max_hunger)
	bt_player.blackboard.set_var("hunger", _hunger)
	
func update_facing_direction(delta: float) -> void:
	controller_rs_input = Input.get_vector("aim_west", "aim_east", "aim_north", "aim_south")
	if accept_player_input:
		if controller_rs_input != Vector2.ZERO:
			facing_direction = controller_rs_input
		elif total_velocity != Vector2.ZERO:
			facing_direction = total_velocity.normalized()
	elif total_velocity != Vector2.ZERO:
		facing_direction = total_velocity.normalized()
		
	if reticle:
		reticle.rotation = lerp_angle(reticle.rotation, facing_direction.angle(), 20 * delta)
		
		
## Updates the creature's velocity by combining navigation and effect velocities.
func update_movement(delta: float) -> void:
	effect_velocity = lerp(effect_velocity, Vector2.ZERO, effect_velocity_decay_factor * delta)
	nav_velocity = nav_velocity
	#linear_velocity = effect_velocity + nav_velocity
	total_velocity = effect_velocity + nav_velocity
	
		
## Applies the current velocity with sliding on collisions using move_and_collide().
func move(delta: float) -> void:
	var motion = total_velocity * delta
	var max_slides = 4  # Safety limit to prevent infinite loops in complex geometry
	var slides = 0
	
	while motion != Vector2.ZERO and slides < max_slides:
		var collision = move_and_collide(motion)
		if collision == null:
			break  # No collision, full motion applied
		
		# Slide the remaining motion along the wall
		motion = collision.get_remainder().slide(collision.get_normal())
		slides += 1
	

	
## Handles health change events targeted at this creature.
func _on_change_health(target: Creature, amount: float, source: Node2D):
	if target == self:
		if amount < 0:
			take_damage(amount, source)
		elif amount > 0:
			heal(amount, source)
			
## Increases the creature's health and emits a healed event.
func heal(amount: float, healer: Node2D):
	_health += amount
	EventBus.creature_healed.emit(self, amount, healer)
	
func go_invincible(duration: float = invincibility_time) -> void:
	if can_go_invincible:
		_invincibility_timer = invincibility_time
		
## Applies damage to the creature if not invincible, updates invincibility, and emits a damaged event.
func take_damage(amount: float, attacker: Node2D) -> bool:
	if can_go_invincible and _invincibility_timer > 0:
		return false
	go_invincible()
	_health += amount
	EventBus.creature_damaged.emit(self, amount, attacker)
	return true
	
	
## Handles the creature's death, emitting a died event and queuing for free.
func die(killer: Node2D) -> void:
	EventBus.creature_died.emit(self, killer)
	queue_free()

## Handles hunger change events targeted at this creature.
func _on_change_hunger(target: Creature, amount: float):
	if target == self:
		if amount < 0:
			satiate_hunger(amount)
		elif amount > 0 :
			give_hunger(amount)
		
## Decreases hunger (satiates) and emits a satiated event.
func satiate_hunger(amount: float):
	_hunger += amount
	EventBus.creature_satiated_hunger.emit(self, amount)

## Increases hunger and emits a got hunger event.
func give_hunger(amount: float):
	_hunger += amount
	EventBus.creature_got_hunger.emit(self, amount)
	


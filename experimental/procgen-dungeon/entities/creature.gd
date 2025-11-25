@tool
extends CharacterBody2D
class_name Creature

# ------------------------------------------------------------------------
# CORE STATS
# ------------------------------------------------------------------------
@export var stat_sheet: CreatureStats

# ------------------------------------------------------------------------
# INTERNAL STATE
# ------------------------------------------------------------------------
@export_subgroup("Internal State")
## Flag to override the creature's health with a custom value.
@export var overriding_health: bool = false
@export var health_override: int = 0
@export var overriding_hunger: bool = false
@export var hunger_override: float = 0
@export var can_go_invincible: bool = true
@export var invincibility_time: float = 2
var _health: int
var _hunger: float
var stats: CreatureStats
var _invincibility_timer: float = 0



# use this velocity for pathfinding, all velocities will be added 
# together on every frame and set to this unit's velocity.
# move_and_slide() should never be called directly in this script
## Velocity used for navigation and pathfinding; combined with other velocities each frame.
var nav_velocity: Vector2 = Vector2.ZERO

# add onto this velocity for temporary effects like knockback
# this variable constantly lerps back to 0
## Temporary velocity for effects like knockback; lerps back to zero over time.
var effect_velocity: Vector2 = Vector2.ZERO
## Decay factor for effect_velocity lerp back to zero.
@export var effect_velocity_decay_factor = 5
## Reference to the NavigationAgent2D node for pathfinding.
@onready var nav_agent: NavigationAgent2D = $NavigationAgent2D
## Reference to the BTPlayer node for behavior tree execution.
@onready var bt_player: BTPlayer = $BTPlayer

# ------------------------------------------------------------------------
# MOVEMENT AND COLLISION FLAGS
# ------------------------------------------------------------------------
@export_subgroup("Movement & Collision")
@export var avoidance_radius: float = 32.0

@export var collide_with_terrain: bool = true
@export var solid_to_creatures: bool = true
@export var use_rvo_avoidance: bool = true

@export var use_pathfinding: bool = true # false -> straight-line movement (ghosts, flyers, etc)


# ------------------------------------------------------------------------
# PLAYER CONTROL
# ------------------------------------------------------------------------
@export_subgroup("Player Possession")
@export var accept_player_input: bool = false

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
	
	if not stats.uuid:
		print(self.name, " ", UUIDGenerator.v4())
		var uuid: String = UUIDGenerator.v4()
		stats.uuid = uuid

func _ready() -> void:
	_ready_statistics()
	
	if $Areas/Hitbox:
		var box: Area2D = $Areas/Hitbox
		box.collision_layer = 1 << 5
		box.collision_mask = 1 << 6
		
	if $Areas/Hurtbox:
		var box: Area2D = $Areas/Hurtbox
		box.collision_layer = 1 << 6
		box.collision_mask = 1 << 5
	
	# register name
	EntityRegister.add_entity_type_to_register(stats.entity_class, stats.entity_type)
	
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

func _process(delta: float) -> void:
	if can_go_invincible:
		_invincibility_timer = max(_invincibility_timer - delta, 0)

func _physics_process(delta: float) -> void:
	update_hunger(delta)
	update_movement(delta)
	
## Increases hunger over time and updates the behavior tree blackboard.
func update_hunger(delta: float) -> void:
	_hunger = min(_hunger + stats.hunger_rate * delta, stats.max_hunger)
	bt_player.blackboard.set_var("hunger", _hunger)
		
## Updates the creature's velocity by combining navigation and effect velocities.
func update_movement(delta: float) -> void:
	effect_velocity = lerp(effect_velocity, Vector2.ZERO, effect_velocity_decay_factor * delta)
	nav_velocity = nav_velocity
	velocity = effect_velocity + nav_velocity
		
## Applies the current velocity using move_and_slide().
func move() -> void:
	#velocity = lerp(velocity, p_velocity, factor)

	move_and_slide()

	
## Handles health change events targeted at this creature.
func _on_change_health(target: Creature, amount: int, source: Node2D):
	if target == self:
		if amount < 0:
			take_damage(amount, source)
		elif amount > 0:
			heal(amount, source)
			
## Increases the creature's health and emits a healed event.
func heal(amount: int, healer: Node2D):
	_health += amount
	EventBus.creature_healed.emit(self, amount, healer)
		
## Applies damage to the creature if not invincible, updates invincibility, and emits a damaged event.
func take_damage(amount: int, attacker: Node2D):
	if can_go_invincible and _invincibility_timer > 0:
		return
	if can_go_invincible:
		_invincibility_timer = invincibility_time
		
	_health += amount
	EventBus.creature_damaged.emit(self, amount, attacker)
	
	
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
	

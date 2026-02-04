extends Node
class_name BrainComponent

## Modular AI Brain using component-based goals and states
## Goals and States are child nodes that can be added/removed or registered at runtime

# ============================================================================
# INTENT (Output)
# ============================================================================
var intent_move_direction: Vector2 = Vector2.ZERO
var intent_action: String = ""
var current_target: Node2D = null

# ============================================================================
# REFERENCES
# ============================================================================
@export var master_origin: Node2D
@export var nutrition_component: NutritionComponent
@export var hunger_component: HungerComponent
@export var health_component: HealthComponent
@export var eye_component: EyeComponent

# ============================================================================
# GOALS & STATES
# ============================================================================
var goals: Dictionary = {}  # goal_name -> GoalComponent
var states: Dictionary = {}  # state_name -> StateComponent
var goal_state_mapping: Dictionary = {}  # goal_name -> state_name

var active_goal: GoalComponent = null
var current_state: StateComponent = null

# ============================================================================
# SIGNALS
# ============================================================================
signal move_input(direction: Vector2)
signal goal_changed(old_goal: GoalComponent, new_goal: GoalComponent)
signal state_changed(old_state: StateComponent, new_state: StateComponent)

# ============================================================================
# INITIALIZATION
# ============================================================================

func _ready() -> void:
	_discover_goals()
	_discover_states()
	_connect_signals()

func _discover_goals():
	# Find all GoalComponent children
	for child in get_children():
		if child is GoalComponent:
			register_goal(child)

func _discover_states():
	# Find all StateComponent children
	for child in get_children():
		if child is StateComponent:
			register_state(child)

func _connect_signals() -> void:
	if health_component:
		health_component.harmed.connect(_on_harmed)

# ============================================================================
# MAIN UPDATE LOOP
# ============================================================================

func _process(delta: float) -> void:
	_evaluate_goals()
	_select_highest_priority_goal()
	_update_active_goal(delta)
	_calculate_intent()
	_update_state_from_goal()
	
	move_input.emit(intent_move_direction)

# ============================================================================
# GOAL SYSTEM
# ============================================================================

func _evaluate_goals():
	for goal in goals.values():
		if goal.enabled:
			goal.update_priority()

func _select_highest_priority_goal():
	if goals.is_empty():
		return
	
	var highest_goal: GoalComponent = null
	var highest_priority = -1.0
	
	for goal in goals.values():
		if goal.enabled and goal.get_priority() > highest_priority:
			highest_priority = goal.get_priority()
			highest_goal = goal
	
	if highest_goal != active_goal:
		_change_active_goal(highest_goal)

func _change_active_goal(new_goal: GoalComponent):
	var old_goal = active_goal
	
	if old_goal:
		old_goal.on_deactivated()
	
	active_goal = new_goal
	if active_goal:
		active_goal.on_activated()
	
	goal_changed.emit(old_goal, new_goal)

func _update_active_goal(delta: float):
	if active_goal:
		active_goal.on_update(delta)

func _calculate_intent():
	if not active_goal:
		intent_move_direction = Vector2.ZERO
		intent_action = ""
		current_target = null
		return
	
	var intent_data = active_goal.calculate_intent()
	
	intent_move_direction = intent_data.get("direction", Vector2.ZERO)
	intent_action = intent_data.get("action", "")
	current_target = intent_data.get("target", null)

# ============================================================================
# STATE SYSTEM
# ============================================================================

func _update_state_from_goal():
	if not active_goal:
		_change_state("idle")
		return
	
	# 1. Check explicit mapping
	if goal_state_mapping.has(active_goal.goal_name):
		var state_name = goal_state_mapping[active_goal.goal_name]
		if states.has(state_name):
			_change_state(state_name)
			return
	
	# 2. Check goal's associated_state property
	if active_goal.associated_state != "" and states.has(active_goal.associated_state):
		_change_state(active_goal.associated_state)
		return
	
	# 3. Fallback: use goal name as state name
	if states.has(active_goal.goal_name):
		_change_state(active_goal.goal_name)
	else:
		# 4. Ultimate fallback
		_change_state("idle")

func _change_state(state_name: String):
	if not states.has(state_name):
		return
	
	var new_state = states[state_name]
	if new_state == current_state:
		return
	
	if current_state:
		current_state.on_exit()
	
	var old_state = current_state
	current_state = new_state
	current_state.on_enter()
	
	state_changed.emit(old_state, new_state)

# ============================================================================
# REGISTRATION API
# ============================================================================

func register_goal(goal: GoalComponent):
	goals[goal.goal_name] = goal
	goal.set_components(self)
	
	# Connect signals
	if not goal.goal_completed.is_connected(_on_goal_completed):
		goal.goal_completed.connect(_on_goal_completed.bind(goal))
	if not goal.goal_failed.is_connected(_on_goal_failed):
		goal.goal_failed.connect(_on_goal_failed.bind(goal))

func register_state(state: StateComponent):
	states[state.state_name] = state
	state.set_components(self)

func map_goal_to_state(goal_name: String, state_name: String):
	goal_state_mapping[goal_name] = state_name

func unregister_goal(goal_name: String):
	if goals.has(goal_name):
		var goal = goals[goal_name]
		goal.goal_completed.disconnect(_on_goal_completed)
		goal.goal_failed.disconnect(_on_goal_failed)
		goals.erase(goal_name)
		goal_state_mapping.erase(goal_name)

# ============================================================================
# GOAL MANAGEMENT
# ============================================================================

func get_goal_by_name(goal_name: String) -> GoalComponent:
	return goals.get(goal_name)

func enable_goal(goal_name: String):
	var goal = get_goal_by_name(goal_name)
	if goal:
		goal.enabled = true

func disable_goal(goal_name: String):
	var goal = get_goal_by_name(goal_name)
	if goal:
		goal.enabled = false
		if active_goal == goal:
			active_goal = null

func get_current_goal_name() -> String:
	if active_goal:
		return active_goal.goal_name
	return ""

func get_current_state_name() -> String:
	if current_state:
		return current_state.state_name
	return ""

# ============================================================================
# EVENT HANDLERS
# ============================================================================

func _on_harmed(amount: float, source: Node2D):
	var flee_goal = get_goal_by_name("flee")
	if flee_goal and flee_goal.has_method("on_harmed"):
		if source and is_instance_valid(source):
			flee_goal.on_harmed(source.global_position)
		else:
			flee_goal.on_harmed(master_origin.global_position + Vector2.from_angle(randf() * TAU) * 100.0)

func _on_goal_completed(goal: GoalComponent):
	# Goal will naturally be replaced by next highest priority
	pass

func _on_goal_failed(goal: GoalComponent):
	# Goal will naturally be replaced by next highest priority
	pass

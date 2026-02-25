class_name Brain
extends Node

signal intent_changed(old_intent: Intent, new_intent: Intent)
signal goal_changed(old_goal_name: String, new_goal_name: String)

@export var creature: Node2D
@export var intent_executor: IntentExecutor

@export var personality: Dictionary[String, float] = {
	"aggression": 0.0,
	"bravery": 0.0,
	"dominance": 0.0,
	"energy": 0.0,
	"nervous": 0.0,
	"sympathy": 0.0
}

# goal management
var goals: Array[Goal] = []
var previous_intent: Intent
var current_intent: Intent
var current_goal: Goal

# memory system for persistent state
var memory: Dictionary = {}

@export var priority_threshold: float = 1.2 # new goal must be this much higher to switch
@export var min_goal_duration: float = 0.1 # minimum time before switching goals

var time_since_goal_change: float = 0.0

func _ready() -> void:
	determine_personality()
	_gather_goals()
	
	current_intent = Intent.new()
	current_intent.action = "idle"
	intent_changed.emit(previous_intent, current_intent)
	

	
func _process(delta: float) -> void:
	time_since_goal_change += delta
	
	var best_goal: Goal = _evaluate_goals()
	
	if _should_switch_goal(best_goal):
		_switch_to_goal(best_goal)
		
func _physics_process(delta: float) -> void:
	if current_intent and intent_executor:
		intent_executor.execute_intent(delta)
		
func _gather_goals() -> void:
	goals.clear()
	for child in get_children():
		if child is Goal:
			goals.append(child)
			
	if goals.is_empty():
		push_warning("[Brain] No goals found for creature")
		

func _evaluate_goals() -> Goal:
	var best_goal: Goal = null
	var highest_priority: float = -INF
	
	for goal in goals:
		var evaluated_priority = goal.evaluate_priority(self)
		
		if not goal.enabled:
			continue
		
		if evaluated_priority > highest_priority:
			highest_priority = evaluated_priority
			best_goal = goal
			
	return best_goal
	
	
func _should_switch_goal(new_goal: Goal) -> bool:
	if current_goal == null:
		return new_goal != null
		
	if new_goal == null:
		return false
		
	if new_goal == current_goal:
		return false
		
	if time_since_goal_change < min_goal_duration:
		return false
	
	var current_priority = current_goal.evaluate_priority(self)
	var new_priority = new_goal.evaluate_priority(self)
	# only switch if new goal is significantly better
	return new_priority > current_priority + priority_threshold
	
	
func _switch_to_goal(new_goal: Goal) -> void:
	var old_goal_name = current_goal.name if current_goal else "none"
	previous_intent = current_intent
	
	current_goal = new_goal
	time_since_goal_change = 0.0
	
	if new_goal == null:
		# this should never happen
		current_intent = Intent.new()
		current_intent.action = "idle"
		current_intent.goal_name = "idle"
	else:
		current_intent = new_goal.generate_intent(self)
		current_intent.goal_name = new_goal.name
		current_intent.priority = new_goal.evaluate_priority(self)
		
	goal_changed.emit(old_goal_name, current_intent.goal_name, current_intent.priority)
	intent_changed.emit(previous_intent, current_intent)
	
func _on_goal_complete(intent: Intent) -> void:
	if intent == current_intent and current_goal:
		current_goal.priority_penalty -= current_goal.completion_penalty
	current_goal = null

func get_current_intent() -> Intent:
	return current_intent
	
func force_reevaluate() -> void:
	var best_goal = _evaluate_goals()
	var old_threshold = priority_threshold
	priority_threshold = -INF
	if _should_switch_goal(best_goal):
		_switch_to_goal(best_goal)
	priority_threshold = old_threshold
	
func determine_personality() -> void:
	personality["aggression"] = randf()
	personality["bravery"] = randf()
	personality["dominance"] = randf()
	personality["energy"] = randf()
	personality["nervous"] = randf()
	personality["sympathy"] = randf()
	

func remember(key: String, value: Variant) -> void:
	memory[key] = value
	
func recall(key: String, default = null) -> Variant:
	return memory.get(key, default)
	
func forget(key: String) -> void:
	memory.erase(key)
	
func has_memory(key: String) -> bool:
	return memory.has(key)
	
func clear_memory() -> void:
	memory.clear()
	
func get_memory_keys() -> Array:
	return memory.keys()

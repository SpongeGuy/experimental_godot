class_name Weapon extends Node

@export var weapon_data: WeaponResource

signal activated(effects: Dictionary) # effects, points on activation

var creature: Creature

var cooldown_timer: Timer

func _instantiate_cooldown_timer() -> void:
	# for weapons which can be shot repeatedly and are not triggered by an external event
	cooldown_timer = Timer.new()
	cooldown_timer.wait_time = weapon_data.base_stats["base_attack_speed"] / creature.creature_stats.attack_speed if weapon_data else null
	cooldown_timer.one_shot = true
	call_deferred("add_child", cooldown_timer)

func _ready() -> void:
	creature = get_parent() as Creature
	
func can_activate() -> bool:
	# by default always ready, but override if necessary
	return true

func activate(target: Node2D = null) -> void:
	if can_activate():
		_perform_attack(target)
		activated.emit(_calculate_attack_effects())
	
func _perform_attack(target: Node2D) -> void:
	# override this, custom attack logic
	pass
	
func add_object_to_world(object: Node2D, creature: Creature):
	var world = get_tree().get_first_node_in_group("world")
	if world:
		world.add_child(object)
	else:
		push_error("No node in group 'world' found! Falling back to creature's parent.")
		creature.get_parent().add_child(object)
	
func _calculate_attack_effects() -> Dictionary:
	var effects: Dictionary = {}
	effects["damage_dealt"] = weapon_data if weapon_data else null
	return effects

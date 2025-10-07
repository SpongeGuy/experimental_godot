class_name Item extends RigidBody2D

@export var is_carryable: bool = true
@export var area: Area2D
@export var allowed_groups: Array[String] = []

var carrier: Creature = null

func _ready() -> void:
	if area:
		area.body_entered.connect(_on_body_entered)
	gravity_scale = 0.0
	linear_damp = 0.5
	angular_damp = 0.5
		
func _on_body_entered(body: Node) -> void:
	if body is Creature and not body.is_dead:
		if allowed_groups.is_empty() or _has_allowed_group(body):
			if is_carryable:
				_pickup(body)
			else:
				_activate(body)
				queue_free()

func _has_allowed_group(creature: Creature) -> bool:
	for group in allowed_groups:
		if creature.is_in_group(group):
			return true
	return false

func _pickup(creature: Creature):
	# this item has been picked up by a creature
	# and will not be activated unless consumed
	# this item can be thrown which will apply forces to the item
	if carrier == null:
		carrier = creature
		area.monitoring = false
		# play some audio
		creature.emit_signal("item_picked_up", self)
		
func consume(creature: Creature) -> void:
	if is_carryable and carrier == creature:
		_activate(creature)
		carrier = null
		queue_free()
	
func _activate(creature: Creature):
	pass

func apply_external_force(force: Vector2, position: Vector2 = global_position):
	if carrier == null:
		apply_impulse(force, position - global_position)

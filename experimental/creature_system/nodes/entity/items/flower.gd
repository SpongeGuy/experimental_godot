extends Item

@export var value: int = 1

func _ready() -> void:
	super._ready()
	is_carryable = false
	print("spawned!")

func _activate(creature: Creature) -> void:
	creature.points += value

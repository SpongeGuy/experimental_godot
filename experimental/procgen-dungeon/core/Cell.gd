class_name Cell
extends RefCounted

signal destroyed(global_pos: Vector2i, flags: int)

enum DestroyFlag {
	NONE = 0,
	EXPLODED = 1 << 0, # bomb blast
	OOZE_EATEN = 1 << 1, # anthurium spread
	BROKEN = 1 << 2, # creature destroyed it by some means
}

enum CellType {NONE, GROUND, SOFT_WALL, HARD_WALL}

var position: Vector2i
var nav_weight: float
var type: CellType
var health: int

func _init(pos: Vector2i) -> void:
	position = pos
	
func take_damage(amount: int, flag: int = DestroyFlag.NONE) -> void:
	if type != CellType.SOFT_WALL:
		return
	health = max(health - amount, 0)
	if health <= 0:
		_die(flag)

func _die(flag: int) -> void:
	type = CellType.NONE
	health = 0
	destroyed.emit(position, flag)


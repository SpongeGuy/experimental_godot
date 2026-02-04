class_name Cell
extends RefCounted

const CELL_SIZE: int = 16

var name: String = ""
var nutrition: float = 0
var moisture: float = 0
var traversability: float = 1.0
var health: float = 100
var max_health: float = 100
var indestructible: bool = false
var type: Type = Type.NULL

enum Type{NULL, GROUND, WALL}

# cell type is chosen through terrain set and terrain id
var terrain_set: int = -1
var terrain: int = -1

# AUTOMATICALLY ASSIGNED VARIABLES
var source_id: int = 0
var atlas_coords: Vector2i = Vector2i(0, 0)
var alternative_tile: int = 0

# growth decay
var growth_timer: float = 0.0
var max_growth_time: float = 10.0
var can_regrow: bool = false

func _init(terr_set: int, terr: int) -> void:
	terrain_set = terr_set
	terrain = terr
	


func process(delta: float):
	pass
	
func take_damage(amount: float) -> bool:
	# returns true if cell was destroyed
	if indestructible:
		return false
		
	health -= amount
	if health <= 0:
		health = 0
		return true
	return false

func is_passable() -> bool:
	return traversability > 0.0
	
func get_movement_modifier() -> float:
	return traversability
	
func is_empty() -> bool:
	return terrain_set == -1 or terrain == -1
	
# STATIC FACTORY METHODS #------------------------------------------------------
# these are helper methods to create cells by terrain type

static func create_empty() -> Cell:
	var cell = Cell.new(-1, -1)
	cell.nutrition = 0.0
	cell.traversability = 1.0
	cell.health = 0.0
	cell.max_health = 0.0
	cell.indestructible = true
	cell.type = Cell.Type.NULL
	return cell

# MORE HELPER METHODS #---------------------------------------


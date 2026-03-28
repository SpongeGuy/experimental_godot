extends Resource
class_name CellData

enum TerrainType { GROUND, WALL, GAP, OUT_OF_BOUNDS }
@export var  terrain: TerrainType = TerrainType.GROUND

var atlas_coordinate: Vector2i = Vector2i.ZERO

@export var invisible: bool = false


var out_of_bounds: bool = false

# ---------------- to be implemented later -----------------------------

@export var movement_multiplier: float = 1.0
@export var friction: float = 1.0
@export var conveyor_velocity: Vector2 = Vector2.ZERO
@export var allow_slip: bool = false
@export var contact_damage: float = 0.0
@export var unidirectional: bool = false
@export var unidirectional_dir: Vector2 = Vector2.ZERO

## designate special entiies that area allowed to walk on this cell
@export var walkable_tags: Array[String] = []

@export_group("Gap")
@export var transport_target: Vector2i = Vector2i.MAX
@export var kill_on_fall: bool = false
@export var fall_damage: float = 0.0

func is_walkable_by(tag: String) -> bool:
	match terrain:
		TerrainType.GROUND:
			return true
		TerrainType.WALL:
			return tag in walkable_tags
		TerrainType.GAP:
			return tag in walkable_tags
	return false

func clone() -> CellData:
	var c = CellData.new()
	c.terrain = terrain
	c.movement_multiplier = movement_multiplier
	c.friction = friction
	c.conveyor_velocity = conveyor_velocity
	c.unidirectional = unidirectional
	c.unidirectional_dir = unidirectional_dir
	c.allow_slip = allow_slip
	c.contact_damage = contact_damage
	c.walkable_tags = walkable_tags.duplicate()
	c.fall_damage = fall_damage
	c.kill_on_fall = kill_on_fall
	c.transport_target = transport_target
	return c

const TERRAIN_ATLAS: Dictionary = {
	CellData.TerrainType.GROUND: Vector2i(0, 0),
	CellData.TerrainType.WALL: Vector2i(1, 0),
	CellData.TerrainType.GAP: Vector2i(2, 0),
}

func resolve_atlas_coordinate() -> void:
	atlas_coordinate = TERRAIN_ATLAS[terrain]

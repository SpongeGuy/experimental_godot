extends Component
class_name ProximityDetector

# --------------------------------------
# interfaces with an area to detect nearby entities (or terrain)
# emits a signal when it detects a nearby entity with a valid script defined in the inspector
# --------------------------------------



@export var area: Area2D

@export_group("Filter")
@export var valid_components: Array[Script]
## if blacklist is enabled, if entity has a component that matches the one in valid_components, it will be discarded.
@export var blacklist: bool = false
@export_enum("has all", "has any") var inclusion: int = 0

@export_group("Collision", "collision")
@export_flags_2d_physics var collision_layer: int
@export_flags_2d_physics var collision_mask: int

signal detected(source: Entity, target: Entity)
signal lost(source: Entity, target: Entity)

signal detected_wall(tile_pos: Vector2i)
signal lost_wall(tile_pos: Vector2i)

func _ready() -> void:
	area.collision_layer = collision_layer
	area.collision_mask = collision_mask
	area.area_entered.connect(_on_area_entered)
	area.area_exited.connect(_on_area_exited)
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)
	
	
# ---------------------------------------------
# detecting entities
# ---------------------------------------------

func _on_area_entered(other: Area2D) -> void:
	var target: Entity = _resolve_entity(other)
	if target and _passes_filter(target):
		detected.emit(entity, target)
		
func _on_area_exited(other: Area2D) -> void:
	var target: Entity = _resolve_entity(other)
	if target and _passes_filter(target):
		lost.emit(entity, target)
		
func _resolve_entity(other: Area2D) -> Entity:
	if other.owner is Entity:
		return other.owner as Entity
	return null
	
func _passes_filter(subject: Entity) -> bool:
	if valid_components.is_empty():
		return true
	
	var has_required: bool
	if inclusion == 0:
		has_required = valid_components.all(func(c): return subject.has_component(c))
	else:
		has_required = valid_components.any(func(c): return subject.has_component(c))
	
	return has_required if not blacklist else not has_required



# --------------------------------------
# probably detecting a wall!
# --------------------------------------

func _resolve_body(other: Node2D) -> TileMapLayer:
	if other is TileMapLayer:
		return other as TileMapLayer
	return null

func _on_body_entered(other: Node2D) -> void:
	if _resolve_body(other):
		detected_wall.emit(WorldGrid.world_to_tile(area.global_position))
		
func _on_body_exited(other: Node2D) -> void:
	if _resolve_body(other):
		lost_wall.emit(WorldGrid.world_to_tile(area.global_position))

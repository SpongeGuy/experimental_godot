extends Component
class_name ObstructionDetector

# -----------------------------------------------------
# interfaces with a proximity detector to tell if the proximity is obstructed with anything
# this is different from ProximityDetector because this component holds a state based on if it is obstructed
# -----------------------------------------------------

@export var proximity: ProximityDetector

var is_facing_obstruction: bool = false

func _ready() -> void:
	proximity.detected.connect(_on_entity_detected)
	proximity.lost.connect(_on_entity_lost)
	proximity.detected_wall.connect(_on_wall_detected)
	proximity.lost_wall.connect(_on_wall_lost)

func _on_entity_detected(source: Entity, t: Entity) -> void:
	is_facing_obstruction = true
	
func _on_entity_lost(source: Entity, t: Entity) -> void:
	is_facing_obstruction = false

func _on_wall_detected(tile_pos: Vector2i) -> void:
	is_facing_obstruction = true
	
func _on_wall_lost(tile_pos: Vector2i) -> void:
	is_facing_obstruction = false

## must be called during _physics_process otherwise it will return stale or empty results
func has_body_at(world_pos: Vector2, mask: int) -> bool:
	var space: PhysicsDirectSpaceState2D = entity.get_world_2d().direct_space_state
	var params: PhysicsPointQueryParameters2D = PhysicsPointQueryParameters2D.new()
	params.position = world_pos
	params.collision_mask = mask
	params.collide_with_areas = true
	params.collide_with_bodies = true
	return not space.intersect_point(params, 1).is_empty()
	


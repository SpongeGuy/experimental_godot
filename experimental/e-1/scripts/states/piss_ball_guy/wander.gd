extends BehaviorState
class_name WandererState

@export var proximity: ProximityDetector
@export var facing: FacingComponent
@export var input: InputComponent
@export var movement: StepMovementComponent
@export var player: SoundPlayer

@export var idle_state: BehaviorState

var target: Entity
var distance_traveled: float = 0.0

func enter() -> void:
	proximity.detected.connect(_on_entity_detected)
	proximity.lost.connect(_on_entity_lost)
	facing.change_direction(Vector2(1, 0))
	
	movement.stepped.connect(_on_stepped)
	
func update(delta: float) -> void:
	pass
	
func physics_update(delta: float) -> void:
	distance_traveled += state_machine.entity.velocity.length()
	var tile_pos_and_facing: CellData = WorldGrid.get_cell(WorldGrid.world_to_tile(state_machine.entity.global_position) + Vector2i(facing.get_direction().round()))
	var is_wall_in_front: bool = tile_pos_and_facing.terrain == CellData.TerrainType.WALL
	#if not is_wall_in_front:
		#state_machine.switch(idle_state)
		#input.move_input_direction = Vector2.ZERO
	input.move_input_direction = facing.get_direction()
	
func exit() -> void:
	pass

func randomly_change_direction() -> void:
	if randf() < 0.5:
		return
		
	var dirs: Array = [
		Vector2(1, 0),
		Vector2(0, 1),
		Vector2(-1, 0),
		Vector2(0, -1)
	]
	
	facing.change_direction(dirs.pick_random())

func _on_stepped() -> void:
	player.play_sound()
	randomly_change_direction()

func _on_entity_detected(source: Entity, t: Entity) -> void:
	target = t
	
func _on_entity_lost(source: Entity, t: Entity) -> void:
	target = null

extends Component
class_name MovementComponent

@export var max_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 800.0 # how fast it stopps
@export var rotation_speed: float = 10.0 # for smooth turning
@export var knockback: KnockbackComponent
@export var world_interface: WorldInterface

var velocity: Vector2 = Vector2.ZERO
var desired_direction: Vector2 = Vector2.ZERO

signal started_moving(direction: Vector2)
signal stopped_moving()
signal changed_direction(old_direction: Vector2, new_direction: Vector2)
signal fell_into_gap(cell: CellData)
signal standing_on_damage(amount: float)

@export var gap_pull_strength: float = 120.0
@export var gap_proximity_radius: float = 12.0
@export var gap_slow_max: float = 0.5
@export var gap_friction_max: float = 0.7

var _gap_speed_scale: float = 1.0
var _gap_friction_scale: float = 1.0

var moving: bool = false

func set_desired_direction(dir: Vector2) -> void:
	if dir.length() > 0:
		desired_direction = dir.normalized()
	else:
		desired_direction = Vector2.ZERO
	
func physics_update(delta: float, body: CharacterBody2D) -> void:
	movement_function(delta, body)
	
	_handle_cell_terrain(body, delta) # cell stuff, ground effects
	#_apply_conveyor(body)
	
	_add_knockback_velocity(body)
	
	_detect_active_movement()
	
	body.move_and_slide()
	
	_handle_bounce_collisions() # knockback purposes
	
	
## applies custom logic to velocity and applies velocity to the body according to conditions
func movement_function(delta: float, body: CharacterBody2D) -> void:
	var final_max_speed: float = max_speed
	var final_friction: float = friction
	
	if world_interface:
		final_max_speed *= world_interface.cell_movement_modifier()
		final_friction *= world_interface.cell_friction_multiplier()
	
	if desired_direction.length() > 0:
		var target_velocity = desired_direction * final_max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, final_friction * delta)
	body.velocity = velocity
	
	


func _handle_cell_terrain(body: CharacterBody2D, delta: float) -> void:
	if not world_interface: 
		return







# ----------------------
# misc
# -------------------------

func _detect_active_movement() -> void:
	if desired_direction.is_zero_approx():
		if moving:
			stopped_moving.emit()
		moving = false
	else:
		if not moving:
			started_moving.emit(velocity.normalized())
		moving = true 
		
	
func get_actual_velocity() -> Vector2:
	return velocity
	
	
# -------------------------
# knockback
# -------------------------	

func _add_knockback_velocity(body: CharacterBody2D) -> void:
	if knockback:
		body.velocity += knockback.knockback_velocity

func _handle_bounce_collisions() -> void:
	if not knockback:
		return
	if owner is not CharacterBody2D:
		return
	if knockback.knockback_velocity.length() > knockback.min_bounce_speed:
		for i in owner.get_slide_collision_count():
			var col: KinematicCollision2D = owner.get_slide_collision(i)
			knockback.knockback_velocity = knockback.knockback_velocity.bounce(col.get_normal()) * knockback.bounce_factor

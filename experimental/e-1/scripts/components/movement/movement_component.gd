extends Component
class_name MovementComponent

@export var max_speed: float = 100.0
@export var acceleration: float = 500.0
@export var friction: float = 800.0 # how fast it stopps
@export var rotation_speed: float = 10.0 # for smooth turning
@export var knockback: KnockbackComponent
@export var world_interface: WorldInterface

@export var apply_acceleration: bool = true
@export var apply_friction: bool = true

var velocity: Vector2 = Vector2.ZERO
var desired_direction: Vector2 = Vector2.ZERO

signal started_moving(direction: Vector2)
signal stopped_moving()



var moving: bool = false

func set_desired_direction(dir: Vector2) -> void:
	if dir.length() > 0:
		desired_direction = dir.normalized()
	else:
		desired_direction = Vector2.ZERO
	
func physics_update(delta: float, body: CharacterBody2D) -> void:
	movement_function(delta)
	_handle_cell_terrain(body, delta) # cell stuff, ground effects
	_apply_knockback(body)
	
	body.velocity = velocity
	body.move_and_slide()
	velocity = body.velocity
	
	_apply_friction(delta)
	
	_handle_passive_collisions(body)
	_handle_bounce_collisions() # knockback purposes

	_detect_active_movement()
	
	
## applies custom logic to velocity and applies velocity to the body according to conditions
func movement_function(delta: float) -> void:
	var final_max_speed: float = max_speed
	
	if world_interface:
		final_max_speed *= world_interface.cell_movement_modifier()
	
	if desired_direction.length() > 0:
		var target_velocity = desired_direction * final_max_speed
		velocity = velocity.move_toward(target_velocity, acceleration * delta)




func _apply_friction(delta: float) -> void:
	if not apply_friction:
		velocity = Vector2.ZERO
		return
	if desired_direction.is_zero_approx():
		velocity = velocity.move_toward(Vector2.ZERO, delta * friction)
	
	


func _handle_cell_terrain(body: CharacterBody2D, delta: float) -> void:
	if not world_interface: 
		return

func _handle_passive_collisions(body: CharacterBody2D) -> void:
	var restitution: float = 1.2
	if entity is not CharacterBody2D:
		return
	
	
	for i in body.get_slide_collision_count():
		var col: KinematicCollision2D = body.get_slide_collision(i)
		var collider_velocity = col.get_collider_velocity()
		var normal: Vector2 = col.get_normal()
		
		var relative_velocity: Vector2 = collider_velocity - velocity
		var push_amount: float = relative_velocity.dot(normal)

		if push_amount > 0:
			velocity += normal * push_amount * restitution



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

func _apply_knockback(body: CharacterBody2D) -> void:
	if knockback:
		velocity += knockback.knockback_velocity

func _handle_bounce_collisions() -> void:
	if not knockback:
		return
	if entity is not CharacterBody2D:
		return
	if knockback.knockback_velocity.length() > knockback.min_bounce_speed:
		for i in entity.get_slide_collision_count():
			var col: KinematicCollision2D = entity.get_slide_collision(i)
			knockback.knockback_velocity = knockback.knockback_velocity.bounce(col.get_normal()) * knockback.bounce_factor

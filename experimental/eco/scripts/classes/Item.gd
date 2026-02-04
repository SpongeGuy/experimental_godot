extends RigidBody2D
class_name Item

@export var physics_collider: CollisionShape2D
@export var main_sprite: Sprite2D

@export_group("Casting")
@export var use_cast_timer: float = 0.0
@export var use_cast_timer_limit: float = 1.0

@export var cast_cooldown_timer: float = 0.0
@export var cast_cooldown_timer_limit: float = 0.0

static func freeze_item(item: Node2D) -> bool:
	if item is RigidBody2D:
		item.process_mode = Node.PROCESS_MODE_DISABLED
		item.freeze = true
		item.physics_collider.disabled = true
		return true
	return false
		
static func unfreeze_item(item: Node2D) -> bool:
	if item is RigidBody2D:
		item.process_mode = Node.PROCESS_MODE_INHERIT
		item.freeze = false
		item.physics_collider.disabled = false
		return true
	return false


func _ready() -> void:
	gravity_scale = 0.0
	collision_layer = (1 << 1)
	collision_mask = (1 << 0) | (1 << 1) | (1 << 2)
	
	lock_rotation = true
	
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC



func try_use(delta: float, user: Creature) -> bool:
	use_cast_timer += delta
	if use_cast_timer >= use_cast_timer_limit:
		use(user)
		use_cast_timer = 0.0
		return true
	return false
		
func use(user: Creature) -> void:
	pass
















# COSMETIC SPRITE FORCES # -----------------------------------------
@export_group("Cosmetic Sprite Physics")
@export var spring_stiffness: float = 300.0
@export var damping_factor: float = 10.0

const MAIN_SPRITE_POS_ORIGIN: Vector2 = Vector2(0.2, -5.0)
var is_grounded: bool = true
var sprite_velocity: Vector2 = Vector2.ZERO



func apply_force_to_sprite(power: float, direction: Vector2 = Vector2.UP) -> void:
	sprite_velocity += direction.normalized() * (power / mass)

func update_sprite_forces(delta: float) -> void:
	# apply gravity to sprite so that it appears to bounce
	
	var displacement: Vector2 = main_sprite.position - MAIN_SPRITE_POS_ORIGIN
	var spring_force: Vector2 = -spring_stiffness * displacement
	var damping_force: Vector2 = -damping_factor * sprite_velocity
	var total_force: Vector2 = spring_force + damping_force
	
	if not is_grounded:
		total_force += Vector2.DOWN * 980.0 * mass
		
	var acceleration: Vector2 = total_force / mass
	sprite_velocity += acceleration * delta
	main_sprite.position += sprite_velocity * delta
	
	_check_ground_collision()
	
func _check_ground_collision() -> void:
	# simple ground check to see if sprite goes below origin
	if main_sprite.position.y > MAIN_SPRITE_POS_ORIGIN.y:
		# hit the "ground"
		main_sprite.position.y = MAIN_SPRITE_POS_ORIGIN.y
		sprite_velocity.y = -sprite_velocity.y * 0.7
		
		if abs(sprite_velocity.y) < 10.0:
			sprite_velocity.y = 0.0
			is_grounded = true
	else:
		is_grounded = false

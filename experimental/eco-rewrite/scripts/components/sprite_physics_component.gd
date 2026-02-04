extends Node
class_name SpritePhysicsComponent

@export var master_origin: RigidBody2D
@export var main_sprite: Sprite2D

@export var spring_stiffness: float = 300.0
@export var damping_factor: float = 10.0

@export var rotate: bool = false

var mass: float

func _ready() -> void:
	mass = master_origin.mass
	

const MAIN_SPRITE_POS_ORIGIN: Vector2 = Vector2(0.2, -5.0)
var is_grounded: bool = true
var sprite_velocity: Vector2 = Vector2.ZERO

func _physics_process(delta: float) -> void:
	update_sprite_forces(delta)
	if rotate:
		rotate_sprite(delta)

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

func rotate_sprite(delta: float) -> void:
	main_sprite.rotation_degrees += (5 * master_origin.linear_velocity.x * delta)

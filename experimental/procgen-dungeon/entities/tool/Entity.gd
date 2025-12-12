extends RigidBody2D
class_name Entity

@export var entity_identification_sheet: EntityIdentification
var identification: EntityIdentification

@export var score: float = 0

func _setup_identification() -> void:
	identification = entity_identification_sheet.duplicate()
	if not identification.uuid:
		var uuid: String = UUIDGenerator.v4()
		identification.uuid = uuid
	EntityManager.add_entity_type_to_register(identification.entity_class, identification.entity_type)

@export var abilities: Dictionary[String, Ability] = {
	"ability_p": null, # pick up ability
	"ability_t": null, # toss / drop ability
	"ability_u": null, # use ability (for items currently picked up)
	
	# passive, active, movement abilities unique to entity
	"ability_1": null,
	"ability_2": null,
	"ability_3": null,
	"ability_4": null,
}

func _update_ability_cooldowns(delta: float) -> void:
	for ability in abilities:
		if abilities[ability] is Ability:
			abilities[ability].update_cooldown(delta)

@export var facing_direction: Vector2 = Vector2.RIGHT


@export_group("Physics Property Overrides")
@export var bounce: float = 0.5
@export var friction: float = 1.0
@export var base_linear_damp: float = 6.0
@export var base_mass: float = 1
@export var absorbent: bool = false

func _setup_physics_properties() -> void:
	physics_material_override = PhysicsMaterial.new()
	physics_material_override.bounce = bounce
	physics_material_override.friction = friction
	physics_material_override.absorbent = absorbent

	linear_damp = base_linear_damp
	mass = base_mass
	gravity_scale = 0.0
	
	lock_rotation = true
	
func _process(delta: float) -> void:
	_update_ability_cooldowns(delta)
	
## this activates the bt_player after this node's children have been set up
## children of this class need to call super._ready() AFTER their overrides, NOT before
func _ready_bt_player_after_waiting() -> void:
	await get_tree().process_frame
	if bt_player:
		bt_player.active = true
	

	
func _ready() -> void:
	EventBus.entity_spawned.emit(position, self)
	_setup_identification()
	_setup_physics_properties()	


var nearby_bodies_in_detection_area: Array[Entity] = []
var nearby_bodies_in_interaction_area: Array[Entity] = []

func _physics_process(delta: float) -> void:
	if interaction_area:
		interaction_area.rotation = facing_direction.angle()
		
	for child in graphical_module.get_children():
		if child is Sprite2D:
			if facing_direction.x < 0.0:
				child.flip_h = true
			else:
				child.flip_h = false

@export_group("References")
@export var physics_box: CollisionShape2D
@export var bt_player: BTPlayer
@export var graphical_module: Node2D
@export var hitbox: Hitbox
@export var hurtbox: Hurtbox ## Disabled by default. Use animationplayers to enable the hurtbox when necessary.
@export var detection_area: DetectionArea
@export var interaction_area: InteractionArea
@export var other_areas: Array[Area2D]


func die(killer: Node2D) -> void:
	queue_free()

class_name Creature extends CharacterBody2D

@export var creature_stats: CreatureResource
@export var brain: AIBrain
@export var weapon: Weapon
#@export var ability: Ability
@export var graphics: Node2D
@export var points: int = 0

@export var hitboxes: Array[CollisionShape2D]
var sound_players: Array[AudioStreamPlayer2D]
var active_voices: Dictionary = {} # key: AudioStreamPlayer2D, Value: int (voice count)

# for player control
@export var under_player_control: bool = false
@onready var mouse_target: Node2D

var is_dead: bool = false

# temporary hurt effect
var hurt_swell_add: float = 1
var current_scale: float = 1.0
var target_scale: float = 1.0
var lerp_speed: float = 15.0

# used to add to final normal velocity
# apply external forces like knockback from explosions to this, then add to `velocity`
var _forces: Vector2

func _ready() -> void:
	for sound_player in get_children(true):
		if sound_player is AudioStreamPlayer2D:
			if not sound_player.finished.is_connected(_on_sound_finished):
				sound_player.finished.connect(_on_sound_finished)
			sound_players.append(sound_player)
			active_voices[sound_player] = 0
	if not active_voices is Dictionary:
		push_error("active_voices is not a Dictionary in _ready: ", active_voices)

func _process(delta: float):
	if current_scale > target_scale:
		current_scale = lerp(current_scale, target_scale, lerp_speed * delta)
		graphics.scale = Vector2(current_scale, current_scale)
	if !mouse_target and under_player_control:
		mouse_target = Node2D.new()
		add_child(mouse_target)
	if under_player_control:
		_player_attack(delta)

func _physics_process(delta: float) -> void:
	if under_player_control:
		_player_control(delta)
	elif brain:
		brain.control(self, delta)

func _scan_nearby(area: Area2D) -> Array:
	return area.get_overlapping_bodies()
	
# change target instantaneously based on encoded priorities
func _prioritize_target(nearby: Array) -> Node2D:
	for node in nearby:
		if node.is_in_group("fruit") and is_in_group("herbivore"):
			return node
		if node.is_in_group("player") and is_in_group("evil"):
			return node
	return nearby[0] if nearby.size() > 0 else null

func add_object_to_world(object: Node2D, creature: Creature):
	var world = get_tree().get_first_node_in_group("world")
	if world:
		world.add_child(object)
	else:
		push_error("No node in group 'world' found! Falling back to creature's parent.")
		creature.get_parent().add_child(object)

func _take_damage(amount: float, origin: Node2D):
	var text_particle: Node2D = preload("res://nodes/effects/text_particle.tscn").instantiate()
	text_particle.create(str(origin.weapon_data.base_damage), position)
	add_object_to_world(text_particle, self)
	if is_dead:
		return
	creature_stats.health -= amount
	if graphics:
		current_scale += hurt_swell_add
		graphics.scale = Vector2(current_scale, current_scale)
	if creature_stats.health <= 0.0:
		_handle_death(origin)

# play animations, award points, steal stats, whatever
func death_effects(killer: Creature) -> void:
	killer.points += creature_stats.point_value

# handle everything related to the self when dying
func _handle_death(origin: Node2D) -> void:
	is_dead = true
	if graphics:
		graphics.visible = false
	if hitboxes:
		for hitbox in hitboxes:
			hitbox.disabled = true
	for sound_player in sound_players:
		active_voices[sound_player] = 0
	if origin.master:
		death_effects(origin.master)
	_check_and_free()
		
func _check_and_free() -> void:
	var total_active_voices: int = 0
	for count in active_voices.values():
		total_active_voices += count
	if is_dead and total_active_voices <= 0:
		print("freeing creature, total active voices: ", total_active_voices)
		queue_free()

func _play_sound(sound_player: AudioStreamPlayer2D, stream: AudioStream) -> void:
	if sound_player and stream:
		sound_player.stream = stream
		sound_player.play()
		active_voices[sound_player] = active_voices.get(sound_player, 0) + 1
		
func _on_sound_finished(sound_player: AudioStreamPlayer2D = null) -> void:
	if sound_player and active_voices.has(sound_player):
		active_voices[sound_player] = max(0, active_voices[sound_player] - 1)
	_check_and_free()
	
func _player_control(delta: float) -> void:
	var input_direction = Input.get_vector("left_input", "right_input", "up_input", "down_input")
	if input_direction.length() >= 1:
		input_direction = input_direction.normalized()
	velocity = input_direction * creature_stats.movement_speed * delta
	move_and_slide()

func _player_attack(delta: float) -> void:
	mouse_target.position = get_global_mouse_position()
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		weapon.activate(mouse_target)

extends Component
class_name HealthComponent

@export var max_health: float
@export var health: float
@export var hitbox: Hitbox ## not mandatory

signal taken_damage(amount: float, source: Node2D)
signal died()

@export var invincibility_length: float = 0.5
var invincibility_timer: float = 0.0

func _ready() -> void:
	if hitbox:
		hitbox.hit_received.connect(take_damage)

func _process(delta: float) -> void:
	_process_invincibility(delta)
	
func _process_invincibility(delta: float) -> void:
	if invincibility_timer >= 0.0:
		invincibility_timer -= delta

func take_damage(amount: float, source: Node2D) -> void:
	if invincibility_timer > 0:
		return
	invincibility_timer = invincibility_length
	health -= amount
	taken_damage.emit(amount, source)
	
	if health <= 0:
		died.emit()

func die() -> void:
	died.emit()

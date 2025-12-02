class_name Detection extends Area2D

@export var master: Entity

func _ready() -> void:
	collision_mask = (1 << 2) | (1 << 4) # look for creatures and fruit
	body_entered.connect(_on_enter_detection)
	body_exited.connect(_on_exit_detection)
	if master.get("bt_player"):
		master.bt_player.blackboard.set_var("Detection", self)

func try_do_damage(area: Area2D):
	if area is Hitbox and area.master != master:
		EventBus.try_change_creature_health.emit(area.master, -master.stats.base_attack_damage, master)

# for organizing nearby nodes
func _on_enter_detection(body: Node2D) -> void:
	if body != self:
		master.nearby_bodies.append(body)
	
func _on_exit_detection(body: Node2D) -> void:
	master.nearby_bodies.erase(body)

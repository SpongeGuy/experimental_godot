class_name Projectile extends CharacterBody2D

var master: Creature

var weapon_data: WeaponResource

func _ready() -> void:
	if master:
		add_collision_exception_with(master)

func _physics_process(delta: float) -> void:
	move_and_slide()
	_collision_logic(delta)
	
	
func _collision_logic(delta: float):
	var processed_colliders: Dictionary  = {}
	for i in get_slide_collision_count():
		var col: KinematicCollision2D = get_slide_collision(i)
		var collider = col.get_collider()
		if collider == null:
			continue
		
		# collect already processed colliders so that they are not counted twice
		var collider_id = collider.get_instance_id()
		if collider_id in processed_colliders:
			continue
		processed_colliders[collider_id] = true
		
		if collider == master:
			pass
		elif collider is Creature:
			var damage = master.weapon.weapon_data.base_damage
			collider._take_damage(damage, self)
			queue_free()
		elif collider is TileMapLayer:
			var damage = master.weapon.weapon_data.base_damage
			var collision_point: Vector2 = col.get_position()
			var normal: Vector2 = col.get_normal()
			var adjusted_point: Vector2 = collision_point - normal * 1.0  # Adjust inward by 1 unit (adjust epsilon as needed based on tile size)
			var tile_pos: Vector2i = collider.local_to_map(collider.to_local(adjusted_point))
			print(collider.get_parent(), tile_pos)
			print("Tile data:", collider.get_cell_tile_data(tile_pos))
			collider.get_parent().damage_tile(tile_pos, damage)
			queue_free()
		elif collider is not CharacterBody2D:
			queue_free()

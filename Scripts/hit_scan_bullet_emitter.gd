extends BulletEmitter

@onready var ray_cast_3d = $RayCast3D
var hit_pos: Vector3
var hit_effect = preload("res://Scenes/bullet_hit_effect.tscn")

@export var muzzle_flash: Node3D



func set_bodies_to_exclude(bodies: Array):
	super(bodies)
	for body in bodies:
		ray_cast_3d.add_exception(body)


func fire():
	ray_cast_3d.enabled = true
	ray_cast_3d.force_raycast_update()
	
	#var start_pos = muzzle_flash.global_position if muzzle_flash else global_position
	var ray_start_pos = ray_cast_3d.global_position
	var ray_end_pos: Vector3
	var hit_something = false
	
	if ray_cast_3d.is_colliding():
		hit_something = true
		ray_end_pos = ray_cast_3d.get_collision_point()
		var collider = ray_cast_3d.get_collider()
		var should_damage = true
		if emitter_owner and emitter_owner.is_in_group("zombies") and collider.is_in_group("zombies"):
			should_damage = false
		if should_damage and collider.has_method("hurt"):
			var damage_data = DamageData.new()
			damage_data.amount = damage
			damage_data.hit_pos = ray_cast_3d.get_collision_point()
			collider.hurt(damage_data)
			print("emitter_owner: ", self.emitter_owner, ", is zombie: ", self.emitter_owner.is_in_group("zombies") if self.emitter_owner else "none")
			print("collider: ", collider, ", groups: ", collider.get_groups())

		else:
			var hit_effect_inst: Node3D = hit_effect.instantiate()
			get_tree().get_root().add_child(hit_effect_inst)
			hit_pos = ray_cast_3d.get_collision_point()
			var hit_normal: Vector3 = ray_cast_3d.get_collision_normal()
			var look_at_pos: Vector3 = hit_pos + hit_normal
			hit_effect_inst.global_position = hit_pos
			if hit_normal.is_equal_approx(Vector3.UP) or hit_normal.is_equal_approx(Vector3.DOWN):
				hit_effect_inst.look_at(look_at_pos, Vector3.UP)
			else:
				hit_effect_inst.look_at(look_at_pos)

	var visual_start_pos = ray_start_pos
	
	if muzzle_flash:
		var shot_vector: Vector3 = ray_end_pos - ray_start_pos
		var shot_direction = shot_vector.normalized()
		
		var cam_to_muzzle: Vector3 = muzzle_flash.global_position - ray_start_pos
		
		var projection_length: float = cam_to_muzzle.dot(shot_direction)
		
		if projection_length > 0.0:
			visual_start_pos = ray_start_pos + (shot_direction * projection_length)
			visual_start_pos = visual_start_pos.lerp(muzzle_flash.global_position, 0.3)
		
	ray_cast_3d.enabled = false
	super()

	
	
	

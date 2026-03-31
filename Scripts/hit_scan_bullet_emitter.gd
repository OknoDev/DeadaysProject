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
	
	var start_point = muzzle_flash.global_position if muzzle_flash else ray_cast_3d.global_position
	var direction = -ray_cast_3d.global_transform.basis.z
	var distance = ray_cast_3d.target_position.length()
	var end_point = start_point + direction * distance
	#var start_pos = muzzle_flash.global_position if muzzle_flash else global_position
	var ray_start_pos = ray_cast_3d.global_position
	var ray_end_pos: Vector3
	var hit_something = false
	
	if ray_cast_3d.is_colliding():
		end_point = ray_cast_3d.get_collision_point()
		hit_something = true
		ray_end_pos = ray_cast_3d.get_collision_point()
		var collider = ray_cast_3d.get_collider()
		var should_damage = true
		if should_damage and collider.has_method("hurt"):
			var damage_data = DamageData.new()
			damage_data.amount = damage
			damage_data.weapon_type = weapon_type
			damage_data.hit_pos = ray_cast_3d.get_collision_point()
			damage_data.anatomy_active = anatomy_active
			collider.hurt(damage_data)
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
		


	
	if muzzle_flash:
		var tracer_scene = preload("res://Scenes/tracer.tscn")
		var tracer = tracer_scene.instantiate()
		get_tree().root.add_child(tracer)
		tracer.init(start_point, end_point)
		var visual_start_pos = ray_start_pos
		ray_cast_3d.enabled = false
	super()

	
	
	

class_name VisionManager extends Node3D

@export var sight_arc = 100.0
@export var max_sight_range = 10.0
@export var always_detect_in_range = 2.0
@onready var player = get_tree().get_first_node_in_group("player")
@onready var los_ray_cast_3d = $LOSRayCast3D

func can_see_target(target:Node3D):
	var target_pos = target.global_position + Vector3.UP * 1.5
	var dir_to_target = global_position.direction_to(target_pos)
	var dist_to_target = global_position.distance_to(target_pos)
	var fwd = -global_transform.basis.z 
	
	if dist_to_target > max_sight_range:
		return false
	
	if dist_to_target < always_detect_in_range:
		return true

	if fwd.angle_to(dir_to_target) > deg_to_rad(sight_arc / 2.0 ):
		return false
	
	los_ray_cast_3d.enabled = true
	los_ray_cast_3d.target_position = los_ray_cast_3d.to_local(target_pos)
	los_ray_cast_3d.force_raycast_update()
	var has_los = !los_ray_cast_3d.is_colliding()
	los_ray_cast_3d.enabled = false
	return has_los

func is_facing_target(target: Node3D):
	var pos = to_local(target.global_position)
	return pos.z < 0.0 and abs(pos.x) < 0.5
	

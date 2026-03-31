extends Node3D

@onready var line_mesh_3d: MeshInstance3D = $LineMesh3D

var speed = 1250.0
var start_pos: Vector3
var end_pos: Vector3
var traveled = 0.0
var total_distance = 0.0

func _ready():
	var rand_scale = randf_range(0.8, 1.2)
	scale = Vector3(rand_scale, rand_scale, rand_scale)
func init(start: Vector3, end: Vector3):
	start_pos = start
	end_pos = end
	total_distance = start_pos.distance_to(end_pos)
	global_position = start_pos

func _process(delta):
	traveled += speed * delta
	var t = traveled / total_distance
	if t >= 1.0:
		queue_free()
		return
	global_position = start_pos.lerp(end_pos, t)

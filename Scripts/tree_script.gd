extends Node3D

func _ready() -> void:
	var a = randf_range(0.6, 1.6) * 40
	scale = Vector3(a, a, a)

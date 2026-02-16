extends Node3D

func _ready():
	for child in get_children():
		child.visible = false
	get_child(randi_range(0, get_child_count() - 1)).visible = true

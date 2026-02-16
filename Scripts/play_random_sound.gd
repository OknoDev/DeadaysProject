extends Node3D

func play():
	for child in get_children():
		child.stop()
	get_child(randi_range(0, get_child_count() - 1)).play()
		

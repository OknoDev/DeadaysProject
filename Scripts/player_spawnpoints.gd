extends Node

@onready var player = get_tree().get_first_node_in_group("player")

func _ready() -> void:	
	player.global_position = get_child(randi_range(0, get_child_count() - 1)).global_position

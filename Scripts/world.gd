extends Node3D

func _ready():
	get_tree().call_group("instanced", "queue_free")
	GameStats.reset_session()

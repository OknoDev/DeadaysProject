extends Node

const MUZZLE_FLASH = preload("res://Materials/muzzle_flash.tres")

func _ready():
	var dummy = MUZZLE_FLASH.instantiate()
	add_child(dummy)
	dummy.visible = false
	var particles = dummy.get_node_or_null("GPUParticles3D")
	if particles:
		particles.restart()
	await get_tree().process_frame
	dummy.queue_free()

extends Node3D
@onready var gpu_particles_3d: GPUParticles3D = $GPUParticles3D

@export var flash_time := 0.05
@onready var weapon_manager: Node3D = %WeaponManager
var timer: Timer
func _ready():
	timer = Timer.new()
	add_child(timer)
	timer.wait_time = flash_time
	timer.one_shot = true
	timer.timeout.connect(end_flash)
	hide()
func flash():
	show()
	gpu_particles_3d.restart()
	if weapon_manager.cur_slot != 3:
		rotation.x = randf_range(0.0, TAU)
	else:
		rotation.y = randf_range(0.0, TAU)
	timer.start()
func end_flash():
	hide()

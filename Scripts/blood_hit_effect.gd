extends Node3D
@onready var spark_particles: GPUParticles3D = $SparkParticles

func _ready() -> void:
	spark_particles.rotation = Vector3(randi_range(0, 360), randi_range(0, 360), randi_range(0, 360))
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 1.5
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(queue_free)
	

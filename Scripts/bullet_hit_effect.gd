extends Node3D

func _ready():	
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 15
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(_on_death_timer_timeout)
			
func _on_death_timer_timeout():
	queue_free()

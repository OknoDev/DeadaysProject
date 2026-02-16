
extends Area3D



func _on_body_entered(body: Node3D) -> void:
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = 20
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(check_deathzone(body))
	
func check_deathzone(body: Node3D):
	if body.is_in_group("zombies"):
		body.queue_free()

	

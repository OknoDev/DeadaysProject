extends Monster

func start_attack():
	super()
	var target_pos = player.global_position + Vector3.UP * 1.5
	var dir_to_player = attack_emitter.global_position.direction_to(target_pos)
	if dir_to_player.is_equal_approx(Vector3.UP) or dir_to_player.is_equal_approx(Vector3.DOWN):
		attack_emitter.look_at(target_pos, Vector3.RIGHT)
	else:
		attack_emitter.look_at(target_pos)

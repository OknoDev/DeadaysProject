extends Marker3D
var bullet_hit_effect_obj = preload("res://Scenes/bullet_hit_effect.tscn")
var spawn_rate = 3.0
var spawn_time = 0.0

func _process(delta):
	spawn_time -= delta
	if spawn_time < 0.0:
		spawn_time = spawn_rate
		var effect_inst = bullet_hit_effect_obj.instantiate()
		effect_inst.global_transform = global_transform
		get_tree().get_root().add_child(effect_inst)
		

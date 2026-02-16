extends Node3D
@onready var camera: Camera3D = $Camera3D
@onready var newRotation: Vector3
var shake_intensity: float = 0.0
var shake_duration: float = 0.0
var shake_timer: float = 0.0
var original_camera_position: Vector3

func _ready():
	original_camera_position = camera.position
	
func _process(delta):
	if shake_timer > 0:
		update_shake(delta)
		
func shake(strength: float = 0.5, duration: float = 0.2):
	shake_intensity = strength
	shake_duration = duration
	shake_timer = duration
	
func update_shake(delta):
	shake_timer -= delta
	
	if shake_timer <= 0:
		camera.position = original_camera_position
		return
	
	var progress = shake_timer / shake_duration
	var current_intensity = shake_intensity * progress
	
	var offset = Vector3( randf_range(-current_intensity, current_intensity), 
	randf_range(-current_intensity, current_intensity),
	randf_range(-current_intensity, current_intensity) * 0.1)
	
	camera.position = original_camera_position + offset
	
	
func change_FOV(current_FOV : int, target_FOV : int, time: float):
	var tween = create_tween()
	tween.tween_property(camera, "fov", target_FOV, time).set_ease(Tween.EASE_OUT)
	
func switch_FOV(current_FOV : int, target_FOV : int, time: float):
	
	var tween = create_tween()
	tween.tween_property(camera, "fov", target_FOV, time).set_ease(Tween.EASE_OUT)
	tween.tween_interval(time)
	tween.tween_property(camera,"fov", current_FOV, time).set_ease(Tween.EASE_OUT)
	
func roll_camera(strength: float = 5.0, duration: float = 0.4):
	var original_roll = 0.0
	var roll_direction = 1 if randi() % 2 == 0 else -1
	var target_roll = original_roll + (strength * roll_direction)
	
	var tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_OUT)
	tween.tween_property(camera, "rotation_degrees:z", target_roll, duration * 0.3)
	tween.tween_property(camera, "rotation_degrees:z", original_roll, duration * 0.7)	
	

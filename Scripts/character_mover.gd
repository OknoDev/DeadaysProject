class_name CharacterMover  extends Node3D
@export var jump_force = 80
@export var gravity = 120.0
@onready var player: CharacterBody3D = $".."

var max_speed = 100
@export var move_accel = 4.0
@export var stop_drag = 0.9
@export var player_jump_sounds: Node3D
var jumps_left: int = 0
var total_jumps: int = 1
@export var is_flying: bool
var character_body: CharacterBody3D
var move_drag := 0.0
var move_dir: Vector3
@export var isSprint = false
@export var isFreeze = false
var settings
var tween : Tween
@export var camera_root: Node3D
@export var camera_3d: Camera3D
signal moved(velocity: Vector3, grounded: bool)
@onready var overlay_animation_player: AnimationPlayer = $"../CameraRoot/Camera3D/PlayerUILayer/StatsDisplay/OverlayAnimationPlayer"
@export var frozen_indicator: ColorRect
@export var indicator_animation_player: AnimationPlayer


@export var wall_jump_vertical_force : float = 110.0
@export var wall_jump_horizontal_force :  float = 180.0
@export var wall_jump_extra_air_control : float = 0.7

var was_on_wall = false
var last_wall_normal : Vector3 = Vector3.ZERO

var base_max_speed: float = 100.0
var base_move_accel: float = 8.0

var sprint_multiplier = 2.0 
var freeze_multiplier: float = 0.5
var knife_speed_multiplier: float = 1.0

func _ready():
	settings = get_node("/root/Settings")
	character_body = get_parent()
	base_max_speed = max_speed
	base_move_accel = move_accel
	move_drag = float(move_accel) / max_speed
func set_move_dir(new_move_dir: Vector3):
	move_dir = new_move_dir
	if not is_flying:
		move_dir.y = 0.0
	move_dir = move_dir.normalized() 
	
func jump():
	if character_body.is_on_wall() and jumps_left == 0:
		last_wall_normal = character_body.get_wall_normal()
		
		if last_wall_normal.length() > 0.1:
			player_jump_sounds.play()
			character_body.velocity.y = 0
			var jump_vector = last_wall_normal * wall_jump_horizontal_force
			jump_vector.y = wall_jump_vertical_force
			camera_root.roll_camera(8.0, 0.5)
			if camera_3d.fov == settings.FOV:
				camera_root.switch_FOV(camera_3d.fov, camera_3d.fov * 1.05, 0.1)
			character_body.velocity += jump_vector
			was_on_wall = false
			jumps_left -= 1
	
	if jumps_left > 0:
		player_jump_sounds.play()
		character_body.velocity.y = jump_force
		if camera_3d.fov == settings.FOV:
			camera_root.switch_FOV(camera_3d.fov, camera_3d.fov * 1.05, 0.1)
		jumps_left -= 1
		was_on_wall = false
		
func set_sprint(active: bool):
	if isFreeze:
		return
	isSprint = active
	update_current_speed()
	if isSprint:
		camera_root.change_FOV(settings.FOV, settings.FOV * 1.1, 0.1)
	else:
		camera_root.change_FOV(settings.FOV * 1.1, settings.FOV, 0.1)

	
func freeze(time: float):
	indicator_animation_player.play("frozen_ind")
	isFreeze = true
	update_current_speed()
	var timer := Timer.new()
	add_child(timer)
	timer.wait_time = time
	timer.one_shot = true
	timer.start()
	timer.timeout.connect(unfreeze)
	overlay_animation_player.play("frozen")
	
func unfreeze():
	indicator_animation_player.play_backwards("frozen_ind")
	update_current_speed()
	isFreeze = false
	overlay_animation_player.play_backwards("frozen")

func set_knife_speed_multiplier(mult: float):
	knife_speed_multiplier = mult
	update_current_speed()
	
func _physics_process(delta):
	if character_body.velocity.y > 0.0 and character_body.is_on_ceiling():
		character_body.velocity.y = 0.0 
		
	
	if not is_flying:
		if not character_body.is_on_floor():
			character_body.velocity.y -= gravity * delta
		if character_body.is_on_floor():
			jumps_left = total_jumps	
		
	
	var drag = move_drag
	if move_dir.is_zero_approx():
		drag = stop_drag

	var flat_velo = character_body.velocity
	if not is_flying:
		flat_velo.y = 0.0
	character_body.velocity += move_accel * move_dir - flat_velo * drag
	
	character_body.move_and_slide()
	moved.emit(character_body.velocity, character_body.is_on_floor())


func set_gravity(new_gravity: float):
	gravity = new_gravity


func update_current_speed():
	var mult = 1.0
	if isSprint:
		mult *= sprint_multiplier
	if isFreeze:
		mult *= freeze_multiplier
	if knife_speed_multiplier != 1.0:
		mult *= knife_speed_multiplier
	max_speed = base_max_speed * mult
	move_accel = base_move_accel * mult
	move_drag = float(move_accel) / max_speed

func set_base_speed(new_max_speed: float, new_move_accel: float):
	base_max_speed = new_max_speed
	base_move_accel = new_move_accel
	update_current_speed()

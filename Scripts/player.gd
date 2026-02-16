extends CharacterBody3D
@onready var settings_menu: Control = $CameraRoot/Camera3D/PlayerUILayer/SettingsMenu

@onready var character_mover: Node3D = $CharacterMover
@onready var health_manager = $HealthManager
@onready var weapon_manager = %WeaponManager

@onready var death_screen: Control = $CameraRoot/Camera3D/PlayerUILayer/DeathScreen
@onready var pause_menu: Control = $CameraRoot/Camera3D/PlayerUILayer/PauseMenu
@export var wave_manager: Node3D
@onready var shop_menu: Control = $CameraRoot/Camera3D/PlayerUILayer/ShopMenu
@onready var stats_display: Control = $CameraRoot/Camera3D/PlayerUILayer/StatsDisplay
@export var settings_manager: Node3D
@onready var overlay_animation_player: AnimationPlayer = $CameraRoot/Camera3D/PlayerUILayer/StatsDisplay/OverlayAnimationPlayer

@onready var camera_3d: Camera3D = $CameraRoot/Camera3D

@export var mouse_sensitivity_h = 0.15
@export var mouse_sensitivity_v = 0.15
var sense_multiply = 1.0

@export var weapon_holder: Node3D
@export var weapon_sway_amount : float
@export var weapon_rotation_amount : float
var default_weapon_holder_pos: Vector3
@export var cam_rotation_amount : float = 0.05
var shop_active = false
@export var points = 0
@onready var camera_root: Node3D = $CameraRoot
@onready var settings = get_node("/root/Settings")
@export var crosshair: TextureRect


var mouse_input: Vector2
const HOTKEYS = {
	KEY_1: 0,
	KEY_2: 1,
	KEY_3: 2,
	KEY_4: 3,
	KEY_5: 4,
	KEY_6: 5,
	KEY_7: 6,
	KEY_8: 7,
	KEY_9: 8,
	KEY_0: 9,
}
var dead = false

func _ready():
	update_settings_from_manager()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	health_manager.died.connect(kill)
	default_weapon_holder_pos = weapon_holder.position
	floor_max_angle = deg_to_rad(60.0)

	add_to_group("game_mode_listeners")




func godmode():
	health_manager.cur_health += 10000
	weapon_manager.cur_weapon.ammo += 1000
	weapon_manager.weapons_unlocked[2] = true
	weapon_manager.weapons_unlocked[3] = true
	



func _input(event):
	if !dead && !get_tree().paused && !shop_active:
		if event is InputEventMouseMotion:
			rotation_degrees.y -= event.relative.x * mouse_sensitivity_h
			camera_3d.rotation_degrees.x -= event.relative.y * mouse_sensitivity_v
			camera_3d.rotation_degrees.x = clamp(camera_3d.rotation_degrees.x, -90, 90)
			mouse_input = event.relative
			
			
		if event is InputEventMouseButton and event.pressed:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				weapon_manager.switch_to_next_weapon()
			if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				weapon_manager.switch_to_previous_weapon()	
		if event is InputEventKey and event.pressed and event.keycode in HOTKEYS:
				weapon_manager.switch_to_weapon_slot(HOTKEYS[event.keycode])
				
	

func _process(_delta):
	if !shop_active:
		if !get_tree().paused:
			##if Input.is_action_just_pressed("alt_attack"):
				##if weapon_manager.cur_slot == 0:
					##weapon_manager.cur_weapon.selfharm()
			#if Input.is_action_just_pressed("godmode"):
				#godmode()
				
			if Input.is_action_just_pressed("sprint") and velocity != Vector3(0,0,0):
				character_mover.isSprint = true
				character_mover.sprint()
				
			if Input.is_action_just_released("sprint"):
				character_mover.isSprint = false
				character_mover.sprint()
				
					
			if Input.is_action_just_pressed("fullscreen"):
				var fs = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
				if fs:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)	 	
				else:
					DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
				
			if dead:
				return
			
			var input_dir = Input.get_vector("move_left", "move_right", "move_forwards", "move_backwards")
			var move_dir = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			cam_tilt(input_dir.x, _delta)
			weapon_tilt(input_dir.x, _delta)
			weapon_sway(_delta)
			character_mover.set_move_dir(move_dir)
			if Input.is_action_just_pressed("jump"):
				character_mover.jump()
			
			weapon_manager.attack(Input.is_action_just_pressed("attack"), Input.is_action_pressed("attack"))	
		

			
		if Input.is_action_just_pressed("quit"):
				if !pause_menu.visible && !settings_menu.visible:
					pause_menu.show()
					stats_display.hide()
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					character_mover.move_accel = 0
					get_tree().paused = true
				elif settings_menu.visible:
					pause_menu.hide()
				else:
					pause_menu.hide()
					stats_display.show()
					Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
					character_mover.move_accel = 8
					get_tree().paused = false
	if Input.is_action_just_pressed("shop"):
			if !shop_active && !wave_manager.is_wave_active:
				shop_menu.show()
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				character_mover.move_accel = 0
				shop_active = true
				stats_display.update_points_display(points)
				shop_menu.update_points_shop_display(points)
			else:
				if !wave_manager.is_wave_active:
					stats_display.update_points_display(points)
					shop_menu.update_points_shop_display(points)
					hide_shop()
				
		
func hide_shop():
	shop_menu.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	character_mover.move_accel = 8
	shop_active = false

	
	
func kill():
	dead = true
	$PlayerDeath.play()
	character_mover.set_move_dir(Vector3.ZERO)
	death_screen.show_death_screen()
	 
	
func hurt(damage_data: DamageData):
	if !dead:
		$PlayerHurtSounds.play()
		health_manager.hurt(damage_data)
		overlay_animation_player.play("damaged")
		print(camera_root.rotation.z)
		camera_root.roll_camera(10.0, 0.5)


func cam_tilt(input_x, delta):
	if camera_root:
		camera_root.rotation.z = lerp(camera_root.rotation.z, -input_x * cam_rotation_amount, 15 * delta)

func weapon_tilt(input_x, delta):
	if weapon_holder:
		weapon_holder.rotation.z = lerp(weapon_holder.rotation.z, -input_x * weapon_rotation_amount, 10 * delta)


func weapon_sway(delta):
	mouse_input = lerp(mouse_input, Vector2.ZERO, 10 * delta)
	weapon_holder.rotation.x = lerp(weapon_holder.rotation.x, mouse_input.y * weapon_sway_amount, 10 * delta)
	weapon_holder.rotation.y = lerp(weapon_holder.rotation.y, mouse_input.x * weapon_sway_amount, 10 * delta)
	
func update_settings_from_manager():
	var settings = get_node("/root/Settings")
	if camera_3d:
		camera_3d.fov = settings.FOV 
	sense_multiply = settings.mouse_sense
	crosshair.visible = settings.crosshair_visible

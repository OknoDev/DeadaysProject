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
@onready var perk_manager: Node = $PerkManager

var base_max_health: int
var base_max_speed: float
var base_move_accel: float
var character_modifiers: Dictionary = {}

var adrenaline_active: bool = false
var adrenaline_regen_timer: Timer


var camera_pitch: float = 0.0
var recoil_offset: float = 0.0
var recoil_decay_rate: float = 40.0
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
	
	base_max_health = health_manager.max_health
	base_max_speed = character_mover.max_speed
	base_move_accel = character_mover.move_accel
	apply_character_modifiers({})	
	$PerkManager.perk_bought.connect(_on_character_perk_bought)
	weapon_manager.weapon_changed.connect(_on_weapon_changed)
	
func godmode():
	health_manager.cur_health += 10000
	weapon_manager.cur_weapon.ammo += 1000
	weapon_manager.weapons_unlocked[2] = true
	weapon_manager.weapons_unlocked[3] = true



func _input(event):
	if event.is_action_pressed("shop"):
		handle_shop_toggle()
	if not dead and event is InputEventKey and not is_input_blocked() and event.pressed and event.keycode in HOTKEYS:
		weapon_manager.switch_to_weapon_slot(HOTKEYS[event.keycode])
	if is_input_blocked():
		return
	
	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity_h * sense_multiply
		camera_pitch -= event.relative.y * mouse_sensitivity_v * 0.01 * sense_multiply
		camera_pitch = clamp(camera_pitch, deg_to_rad(-90), deg_to_rad(90))
		mouse_input = event.relative
			
			
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			weapon_manager.switch_to_next_weapon()
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			weapon_manager.switch_to_previous_weapon()	



func _process(_delta):
	recoil_offset = move_toward(recoil_offset, 0.0, deg_to_rad(recoil_decay_rate) * _delta)
	camera_3d.rotation.x = camera_pitch + recoil_offset
		
	if is_input_blocked():
		return
	
	GameStats.update_time(_delta)
			
	if Input.is_action_just_pressed("sprint") and velocity != Vector3(0,0,0):
		character_mover.set_sprint(true)
			
	if Input.is_action_just_released("sprint"):
		character_mover.set_sprint(false)

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
				if shop_active:
					hide_shop()
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
				character_mover.move_accel = character_mover.update_current_speed()
				get_tree().paused = false
		
func hide_shop():
	shop_menu.hide()
	shop_active = false
	if not get_tree().paused and not pause_menu.visible and not settings_menu.visible:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		character_mover.move_accel = 8
	
	
func kill():
	dead = true
	$PlayerDeath.play()
	GameStats.end_game()
	character_mover.set_move_dir(Vector3.ZERO)
	death_screen.show_death_screen()
	 
	
func hurt(damage_data: DamageData):
	if !dead:
		$PlayerHurtSounds.play()
		health_manager.hurt(damage_data)
		overlay_animation_player.play("damaged")
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

func apply_character_modifiers(new_mods: Dictionary):
	for key in new_mods:
		character_modifiers[key] = character_modifiers.get(key, 0) + new_mods[key]
	apply_character_stats()
	
func apply_character_stats():
		var health_bonus = character_modifiers.get("health", 0)
		health_manager.max_health = base_max_health + health_bonus
		if health_manager.cur_health > health_manager.max_health:
			health_manager.cur_health = health_manager.max_health
		stats_display.update_health_display(health_manager.cur_health,health_manager.max_health)
		var speed_bonus = character_modifiers.get("speed", 0)
		var new_max_speed = base_max_speed * (1.0 + speed_bonus)
		var new_move_accel = base_move_accel * (1.0 + speed_bonus)
		character_mover.set_base_speed(new_max_speed, new_move_accel)
		
func start_adrenaline_regen():
	if adrenaline_active:
		return
	adrenaline_active = true
	if adrenaline_regen_timer and adrenaline_regen_timer.is_inside_tree():
		return
	adrenaline_regen_timer = Timer.new()
	adrenaline_regen_timer.wait_time = 2.5
	adrenaline_regen_timer.one_shot = false
	adrenaline_regen_timer.timeout.connect(_on_adrenaline_regen)
	add_child(adrenaline_regen_timer)
	adrenaline_regen_timer.start()

func _on_adrenaline_regen():
	if health_manager.cur_health < health_manager.max_health:
		health_manager.heal(1)


func _update_knife_speed_buff():
	var fast_knife_perk = preload("res://Scripts/Perks/Knife/fast_knife.tres")
	if perk_manager.is_perk_bought(fast_knife_perk) and weapon_manager.cur_slot == 0:
		character_mover.set_knife_speed_multiplier(1.15)
	else:
		character_mover.set_knife_speed_multiplier(1.0)

func _on_weapon_changed(_slot: int):
	_update_knife_speed_buff()

func _on_character_perk_bought(perk: Perk):
	if perk.perk_type == 0:
		if perk is StatPerk:
			apply_character_modifiers(perk.modifiers)
			
func on_zombie_killed():
	var current_weapon = weapon_manager.cur_weapon
	if not current_weapon:
		return
	var trophy_perk = preload("res://Scripts/Perks/M16/trophy_ammo.tres")
	if current_weapon.weapon_type == 3 and perk_manager.is_perk_bought(trophy_perk):
		current_weapon.add_ammo(2)
	var blood_perk = preload("res://Scripts/Perks/Knife/blood_harvest.tres")
	if current_weapon.weapon_type == 1 and perk_manager.is_perk_bought(blood_perk):
		health_manager.heal(10)
	
func apply_recoil(strength_degrees: float):
	var target_offset = recoil_offset + deg_to_rad(strength_degrees)
	target_offset = clamp(target_offset, deg_to_rad(-30), deg_to_rad(30))
	var tween = create_tween()
	tween.tween_property(self, "recoil_offset", target_offset, 0.05)


func is_input_blocked() -> bool:
	return dead or get_tree().paused or shop_active or pause_menu.visible or settings_menu.visible

func handle_shop_toggle():
	if get_tree().paused or pause_menu.visible:
		return
	if not shop_active && not wave_manager.is_wave_active:
		shop_menu.show()
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		character_mover.move_accel = 0
		shop_active = true
		stats_display.update_points_display(points)
		shop_menu.update_points_shop_display(points)	
	elif shop_active:
		hide_shop()

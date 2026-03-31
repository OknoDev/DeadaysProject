extends Node3D

@onready var spawn_timer = $Timer
const AMMO_PICKUP = preload("res://Scenes/ammo_pickup.tscn")
const HEALTH_PICKUP = preload("res://Scenes/health_pickup.tscn")
const PISTOL_AMMO_PICKUP = preload("res://Scenes/pistol_ammo_pickup.tscn")
const SHOTGUN_AMMO_PICKUP = preload("res://Scenes/shotgun_ammo_pickup.tscn")
@onready var spawn_area: Area3D = $Area3D
@onready var collision_shape_3d: CollisionShape3D = $Area3D/CollisionShape3D
@onready var player = get_tree().get_first_node_in_group("player")
@onready var weapon_manager: Node3D
@onready var makarov: Weapon 
@onready var shotgun: Weapon
@onready var m_4a_1: Weapon
func _ready():
	weapon_manager = player.get_node("CameraRoot/Camera3D/WeaponManager")
	makarov = player.get_node("CameraRoot/Camera3D/WeaponManager/Weapons/Makarov")
	shotgun = player.get_node("CameraRoot/Camera3D/WeaponManager/Weapons/Shotgun")
	m_4a_1 = player.get_node("CameraRoot/Camera3D/WeaponManager/Weapons/M4A1")
	spawn_timer.wait_time = randf_range(30.0, 45.0)
	choose_to_spawn()
	

func _on_timer_timeout() -> void: 

	if !has_overlapping_pickups():
		var indx_pickup: int = randi_range(0, 3)
		choose_to_spawn()
	
	
	spawn_timer.wait_time = randf_range(15.0, 25.0)
	
func spawn_pickup(pickup):
	var newPickup = pickup.instantiate()
	get_parent().call_deferred("add_child", newPickup)
	newPickup.call_deferred("set_global_position", global_position)
	
	
	

func has_overlapping_pickups() -> bool:
	var overlapping_areas = spawn_area.get_overlapping_areas()
	for area in overlapping_areas:
		if area.is_in_group("pickup"):
			return true
	return false
	
func choose_to_spawn():
	var indx_pickup: int = randi_range(0, 3)
	match indx_pickup:
		0:		
			if weapon_manager.weapons_unlocked[2] and m_4a_1.ammo != m_4a_1.max_ammo:
				spawn_pickup(AMMO_PICKUP)
			else:
				choose_to_spawn()
		1:
			if player.health_manager.cur_health >= player.health_manager.max_health:
				choose_to_spawn()
			else:
				spawn_pickup(HEALTH_PICKUP)
		2:
			if weapon_manager.weapons_unlocked[1]:
				spawn_pickup(PISTOL_AMMO_PICKUP)
			else:
				choose_to_spawn()
		3:
			if weapon_manager.weapons_unlocked[3] and shotgun.ammo != shotgun.max_ammo:
				spawn_pickup(SHOTGUN_AMMO_PICKUP)
			else:
				choose_to_spawn()
			

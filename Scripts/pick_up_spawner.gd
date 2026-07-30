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
	
	var need_health = player.health_manager.cur_health < player.health_manager.max_health
	var ammo_candidates = []
	
	if weapon_manager.weapons_unlocked[1]:
		if makarov.ammo < makarov.max_ammo:
			var deficit = makarov.max_ammo - makarov.ammo
			ammo_candidates.append({"deficit": deficit, "scene": PISTOL_AMMO_PICKUP})

	if weapon_manager.weapons_unlocked[2]:
		if m_4a_1.ammo < m_4a_1.max_ammo:
			var deficit = m_4a_1.max_ammo - m_4a_1.ammo
			ammo_candidates.append({"deficit": deficit, "scene": AMMO_PICKUP})
					
	if weapon_manager.weapons_unlocked[3]:
		if shotgun.ammo < shotgun.max_ammo:
			var deficit = shotgun.max_ammo - shotgun.ammo
			ammo_candidates.append({"deficit": deficit, "scene": SHOTGUN_AMMO_PICKUP})
		
	var rnd = randf()
	var spawn_health = false
	var chosen_ammo = null
	
	if need_health and rnd < 0.3:
		spawn_health = true
	elif not ammo_candidates.is_empty():
		ammo_candidates.sort_custom(func(a, b): return a.deficit > b.deficit)
		chosen_ammo = ammo_candidates[0].scene
	else:
		spawn_health = true
	
	if spawn_health:
		spawn_pickup(HEALTH_PICKUP)
	elif chosen_ammo:
		spawn_pickup(chosen_ammo)

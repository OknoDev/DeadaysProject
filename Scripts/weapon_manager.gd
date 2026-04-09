extends Node3D
@onready var weapons = $Weapons.get_children()
@export var weapons_unlocked = []
var cur_slot = -1
var cur_weapon = null
@export var animation_player : AnimationPlayer 
#@onready var camera_recoil: ProceduralRecoil = $"../.."

signal weapon_changed(slot: int)

func _ready():
	
	disable_all_weapons()
	for _i in range(weapons.size()):
		weapons_unlocked.append(false)
	weapons_unlocked[0] = true
	weapons_unlocked[1] = true
	switch_to_weapon_slot(0)
func attack(input_just_pressed: bool, input_held: bool):
	if cur_weapon is Weapon:
		cur_weapon.attack(input_just_pressed, input_held)

	

		

func disable_all_weapons():
	for weapon in weapons:
		if weapon.has_method("set_active"):
			weapon.set_active(false)
		else:
			weapon.hide()
	
func switch_to_previous_weapon():
	for i in range(weapons.size()):	
		var wrapped_ind = wrapi(cur_slot - 1 - i, 0, weapons.size())
	
		if switch_to_weapon_slot(wrapped_ind):
			break
			
func switch_to_next_weapon():
	for i in range(weapons.size()):	
		var wrapped_ind = wrapi(cur_slot + 1 + i, 0, weapons.size())
		if switch_to_weapon_slot(wrapped_ind):
			break
	
func switch_to_weapon_slot(slot_ind: int) -> bool:
	if cur_slot != slot_ind:
		if slot_ind >= weapons.size() or slot_ind < 0:
			return false
		
		if weapons_unlocked.size() == 0 or !weapons_unlocked[slot_ind]:
			return false
	
		disable_all_weapons()
		cur_slot = slot_ind
		cur_weapon = weapons[cur_slot]
		cur_weapon.animation_player.play("pickup")
		weapon_changed.emit(cur_slot)
		if cur_weapon.has_method("set_active"):
			cur_weapon.set_active(true)
		
		else:
			cur_weapon.show()
		return true
	return true
	

func update_animation(velocity: Vector3, grounded: bool):
	if cur_weapon is Weapon and cur_weapon.is_idle():
		animation_player.play("RESET")
	elif !grounded or velocity.length() < 5.0:
		animation_player.play("moving", 0.3, 0.3)
	else:
		animation_player.play("moving", 0.3, 1.75)	
	

func get_weapon_from_pickup_type(weapon_type: Pickup.WEAPONS) -> Weapon:
	match weapon_type:
		Pickup.WEAPONS.RIFLE:
			return $Weapons/M4A1
		Pickup.WEAPONS.SHOTGUN:
			return $Weapons/Shotgun
		Pickup.WEAPONS.PISTOL: 
			return $Weapons/Makarov
	return null

func get_weapon_by_type(weapon_type: int) -> Weapon:
	for weapon in weapons:
		if weapon is Weapon and weapon.weapon_type == weapon_type:
			return weapon
	return null
	

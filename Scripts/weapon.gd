extends Node3D

class_name Weapon
@onready var character_mover: Node3D = $"../../../../../CharacterMover"
@export var animation_player : AnimationPlayer
@onready var bullet_emitter = $BulletEmitter
@onready var fire_point : Node3D = %FirePoint
@onready var weapon_manager = %WeaponManager
@export var automatic = false
@export var damage = 5
@export var ammo = 30
@export var max_ammo = 30
@export var attack_rate = 0.2
@export var damage_multiply = 1.0
var last_attack_time = -9999.9
@onready var shotgun_cock: AudioStreamPlayer = $"../Shotgun/ShotgunCock"
@onready var player: CharacterBody3D = $"../../../../.."
@export var voice_line_probability: float = 0.1
@onready var camera_root: Node3D = $"../../../.."

signal fired
signal out_of_ammo
signal ammo_updated(ammo_amnt: int, max_ammo: int)
@export var muzzle_flash: Node3D
@export var hitscan_emitter: Node3D

@export var weapon_type: int = 2
var base_damage: int
var base_max_ammo: int
var base_attack_rate: float

var stat_modifiers: Dictionary = {}

var anatomy_active: bool = false
var buckshot_active: bool = false
var trophy_ammo_active: bool = false
var base_burst_count: int = 5 

func _ready():
	update_damage()
	base_damage = damage
	base_max_ammo = max_ammo
	base_attack_rate = attack_rate
	apply_stat_modifiers()
	%PerkManager.perk_bought.connect(_on_perk_bought)
	if weapon_type == 4:
		var burst_emitter = find_child("BurstEmitter")
		if burst_emitter:
			base_burst_count = burst_emitter.burst_count

func update_damage():
	bullet_emitter.set_damage(damage * damage_multiply)

func set_bodies_to_exclude(bodies: Array):
	bullet_emitter.set_bodies_to_exclude(bodies)
	
func attack(input_just_pressed: bool, input_held: bool):
	if !automatic and !input_just_pressed:
		return
	if automatic and !input_held:
		return
	
	if ammo == 0:
		if input_just_pressed:
			out_of_ammo.emit()
			if has_node("EmptySound"):
				$EmptySound.play()
		return
	var cur_time = Time.get_ticks_msec() / 1000.0
	
	if cur_time - last_attack_time < attack_rate:
		return
	
	if ammo > 0 and weapon_manager.cur_slot != 0:
		ammo -= 1
	
	var recoil_strength = 5.0
	match weapon_type:
		1: recoil_strength = 0.5
		2: recoil_strength = 3.0
		3: recoil_strength = 4.5
		4: recoil_strength = 8.0
	player.apply_recoil(recoil_strength)
		
		
	bullet_emitter.global_transform = fire_point.global_transform
	bullet_emitter.weapon_type = weapon_type
	bullet_emitter.anatomy_active = anatomy_active

	bullet_emitter.fire()
	
	fired.emit()
	last_attack_time = cur_time
	animation_player.stop()
	if weapon_manager.cur_slot == 2:
		animation_player.play("attack", 1.0, 1.75)
	else:
		animation_player.play("attack", 1.0, 2.0)
	$AttackSounds.play()
	if randf() < voice_line_probability:
		$"../../../../../PlayerPhrasesSounds".play()
	if weapon_manager.cur_slot == 3:
		shotgun_cock.play()
	ammo_updated.emit(ammo, max_ammo)
	if muzzle_flash != null:
		muzzle_flash.flash()
		
		
func set_active(a: bool):
	visible = a
	if !a:
		animation_player.play("RESET")
	else:
		ammo_updated.emit(ammo, max_ammo)

		
func is_idle() -> bool:
	return animation_player.is_playing()
		
func add_ammo(amnt : int):

	ammo = clamp(ammo + amnt, 0, max_ammo)
	ammo_updated.emit(weapon_manager.cur_weapon.ammo, weapon_manager.cur_weapon.max_ammo)

func inspection():
	animation_player.play("inspection")
	
func selfharm():
	animation_player.play("selfharm")

func apply_modifiers(new_mods: Dictionary):
	for key in new_mods:
		stat_modifiers[key] = stat_modifiers.get(key, 0) + new_mods[key]
	apply_stat_modifiers()
	
func apply_stat_modifiers():
	damage = base_damage + stat_modifiers.get("damage", 0)
	max_ammo = base_max_ammo + stat_modifiers.get("magazine", 0)
	var fire_rate_mod = stat_modifiers.get("fire_rate", 0.0)
	attack_rate = base_attack_rate / (1.0 + fire_rate_mod)
	ammo = min(ammo, max_ammo)
	update_damage()
	ammo_updated.emit(ammo, max_ammo)
	

func set_anatomy_active(active: bool):
	anatomy_active = active
	
func set_buckshot_active(active: bool):
	buckshot_active = active
	if buckshot_active and weapon_type == 4:
		var burst_emitter = find_child("BurstEmitter")
		if burst_emitter:
			burst_emitter.burst_count = base_burst_count * 2
			
func set_trophy_ammo_active(active: bool):
	trophy_ammo_active = active

	
func _on_perk_bought(perk: Perk):
	if perk.perk_type == weapon_type:
		apply_stat_modifiers()
		

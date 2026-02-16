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


func _ready():
	update_damage()



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
		
	bullet_emitter.global_transform = fire_point.global_transform
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

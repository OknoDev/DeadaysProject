extends Node3D
# ЭТО ТОЛЬКО ДЛЯ ЗОМБИ!

const EXPLOSION_PARTICLE = preload("res://Scenes/explosion_particle.tscn")
const ICE_EXPLOSION_PARTICLE = preload("res://Scenes/ice_explosion_particle.tscn")
const BLOOD_HIT_EFFECT = preload("res://Scenes/blood_hit_effect.tscn")
const BLOOD_DECAL = preload("res://Scenes/blood_decal.tscn")
const GIB = preload("res://Scenes/gib.tscn")
const BLOOD_CLOUD = preload("res://Scenes/blood_gib_cloud.tscn")
@onready var blood_raycast: RayCast3D = $BloodRaycast
const SKULL_GIB = preload("res://Scenes/skull_gib.tscn")

@export var max_health = 100
@onready var cur_health = max_health
@export var gib_when_damage_taken = 20
var has_gibbed = false
@export var blood_splatter_count = 3
@export var blood_splatter_range = 2.0
@export var blood_splatter_size_variance = 0.5
@export var gib_spawn_amnt: int
@export var verbose = false

signal died
signal damaged
signal gibbed
signal health_change(cur_health, max_health)

var damage_taken_this_frame = 0
var last_frame_damaged = -1
var is_flying: bool = false
var is_freezing: bool = false
var is_award_death: bool = false
func _ready():
	health_change.emit(cur_health, max_health)

func hurt(damage_data: DamageData):
	if cur_health <= 0:
		return
		
	if !is_flying:
		spawn_blood_effects(damage_data)	
	if is_award_death:
		$"../HurtBloodSound".pitch_scale = randf_range(0.9, 1.1)
		$"../HurtBloodSound".play()
		$"../ZombieHurtSounds".play()

	var cur_frame = Engine.get_process_frames()
	if last_frame_damaged != cur_frame:
		damage_taken_this_frame = 0
	last_frame_damaged = cur_frame
	damage_taken_this_frame += damage_data.amount
	
	cur_health -= damage_data.amount


	if cur_health <= 0:
		died.emit()
		
		if is_flying:
			gibbed.emit()
			gib(damage_data)
		else:
			# Для обычных зомби – если урон превышает порог
			if damage_data.amount >= gib_when_damage_taken:
				gibbed.emit()
				gib(damage_data)
	else:
		damaged.emit()
	
	health_change.emit(cur_health, max_health)

func gib(damage_data: DamageData):
	if has_gibbed:
		return
	has_gibbed = true
	gibbed.emit()
	
	if !is_flying:
		var blood_cloud_inst = BLOOD_CLOUD.instantiate()
		blood_cloud_inst.add_to_group("instanced")
		get_tree().get_root().add_child(blood_cloud_inst)
		blood_cloud_inst.global_position = global_position
	else:
		if is_freezing:
			var explosion_inst = ICE_EXPLOSION_PARTICLE.instantiate()
			explosion_inst.add_to_group("instanced")
			get_tree().get_root().add_child(explosion_inst)
			explosion_inst.global_position = global_position
		else:
			var explosion_inst = EXPLOSION_PARTICLE.instantiate()
			explosion_inst.add_to_group("instanced")
			get_tree().get_root().add_child(explosion_inst)
			explosion_inst.global_position = global_position
	
	for _i in gib_spawn_amnt:
		var gib_inst
		if is_flying:
			gib_inst = SKULL_GIB.instantiate()
		if is_award_death:
			gib_inst = GIB.instantiate()
		else:
			return
		get_tree().get_root().add_child(gib_inst)
		gib_inst.global_position = damage_data.hit_pos
		gib_inst.add_to_group("instanced")

# Остальные функции для крови (скопируй из старого HealthManager)
func spawn_blood_effects(damage_data: DamageData):
	if get_parent().is_in_group("zombies"):
		var blood_hit_effect = BLOOD_HIT_EFFECT.instantiate()
		get_tree().get_root().add_child(blood_hit_effect)
		blood_hit_effect.global_position = damage_data.hit_pos
	
	# Создаем временный RayCast3D для определения поверхностей
		var blood_raycast = RayCast3D.new()
		add_child(blood_raycast)
		blood_raycast.enabled = true
		blood_raycast.collision_mask = 1  # Убедитесь, что маска соответствует слоям стен
	
		for i in range(blood_splatter_count):
			var h_angle = randf_range(0.0, PI / 2.0)
			var v_angle = randf_range(0.0, TAU)
			var dir = Vector3.DOWN.rotated(Vector3.RIGHT, h_angle)
			dir = dir.rotated(Vector3.UP, v_angle)
			
			# Устанавливаем начало и конец луча
			blood_raycast.global_position = damage_data.hit_pos
			blood_raycast.target_position = dir * blood_splatter_range
			
			# Обновляем луч
			blood_raycast.force_raycast_update()
			
			if blood_raycast.is_colliding():
				var hit_pos = blood_raycast.get_collision_point()
				var hit_normal = blood_raycast.get_collision_normal()
				
				# Замените в цикле создание декали на:
				var decal = Decal.new()
				decal.set_script(load("res://Scripts/bullet_hit_effect.gd")) 
				decal.texture_albedo = preload("res://Textures/blood_splash.png")

				decal.size = Vector3(30.0, 10.0, 30.0)  # Очень тонкий по Z
				get_tree().get_root().add_child(decal)
				decal.global_position = hit_pos
				decal.add_to_group("instanced")
				decal.look_at(hit_pos + hit_normal, Vector3.UP)
				decal.rotate_object_local(Vector3(1, 0, 0), 90)
				decal.rotate_object_local(Vector3(0, 1, 0), randf_range(0, TAU))
				# Отладочный вывод
				
		
		# Удаляем временный RayCast
		blood_raycast.queue_free()

func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health = clamp(cur_health + amount, 0, max_health)
	health_change.emit(cur_health, max_health)

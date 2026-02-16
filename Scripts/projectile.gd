class_name Projectile
extends Node3D

@onready var collision_ray_cast: RayCast3D = $CollisionRayCast

@export var speed = 30
@export var show_after_time := 0.1
@export var delete_on_hit_after_time := 0.0

const MAX_PROJECTILE_LIFESPAWN := 10.0
var bodies_to_exclude = []
var damage = 1

var last_pos : Vector3

signal hit_something
func _ready():
	hide()
	await get_tree().create_timer(show_after_time).timeout
	show()
	await get_tree().create_timer(MAX_PROJECTILE_LIFESPAWN).timeout
	queue_free()
	
func set_bodies_to_exclude(bte: Array):
	bodies_to_exclude = bte
	for b in bte:
		collision_ray_cast.add_exception(b)

func _physics_process(delta: float) -> void:
	process_movement(delta)
	check_collisions()
	
func process_movement(delta):
	last_pos = global_position
	global_position += -global_transform.basis.z * speed * delta
	
func check_collisions():
	collision_ray_cast.global_position = last_pos
	collision_ray_cast.target_position = collision_ray_cast.to_local(global_position)
	collision_ray_cast.enabled = true
	var is_colliding = collision_ray_cast.is_colliding()
	var hit_pos = collision_ray_cast.get_collision_point()
	var hit_normal = collision_ray_cast.get_collision_normal()
	var hit_collider = collision_ray_cast.get_collider()
	collision_ray_cast.enabled = false
	
	if is_colliding:
		on_hit(hit_collider, hit_pos, hit_normal)
		

func on_hit(hit_collider: Node3D, hit_pos: Vector3, hit_normal: Vector3):
	global_position = hit_pos
	hit_something.emit()

	if hit_collider.has_method("hurt"):
		damage_target(hit_collider, hit_pos, hit_normal)
	destroy()
	
func damage_target (hit_collider: Node3D, hit_pos: Vector3, hit_normal: Vector3):
	var damage_data = DamageData.new()
	damage_data.amount = damage
	damage_data.hit_pos = hit_pos
	hit_collider.hurt(damage_data)
	
	
	
func destroy():
	if delete_on_hit_after_time > 0:
		$Graphics.hide()
		set_process(false)
		set_physics_process(false)
		await get_tree().create_timer(show_after_time).timeout
		queue_free()
	else:
		queue_free()

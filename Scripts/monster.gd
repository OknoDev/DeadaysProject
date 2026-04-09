class_name Monster extends CharacterBody3D

@onready var zombie_health_manager: Node3D = $ZombieHealthManager

@export var animation_player: AnimationPlayer
enum STATES {IDLE, ATTACK, DEAD}
var cur_state = STATES.IDLE
@export var skeleton: Skeleton3D
@onready var vision_manager: Node3D = $VisionManager
@onready var ai_character_mover: Node3D = $AICharacterMover
@onready var player = get_tree().get_first_node_in_group("player")
@onready var attack_emitter: BulletEmitter = $AttackEmitter
@export var attack_range = 2.0 
@export var damage = 15
signal died(zombie_type)
@export var point_amount = 10
@export var is_flying: bool
#port_category("Zombie Type Setting")
@export var zombie_health: int
@export var zombie_damage: int
@export var zombie_speed: float = 2.0
@export var zombie_attack_range: float = 2.0
@export var zombie_point_amount: int = 10
@export var zombie_type: String = "Zombie"
@onready var zombie_hurt_sounds: Node3D = $ZombieHurtSounds
@onready var hurt_blood_sound: AudioStreamPlayer = $HurtBloodSound
@onready var zombie_collision: StaticBody3D = $ZombieCollision
@onready var ai_timer: Timer = $AITimer

var current_tween: Tween = null

var ai_timer_min_value: float = 0.05
var ai_timer_max_value: float = 0.2

var wave_manager: Node

var award_points_on_death: bool = true

var attack_range_vertical: float = 35.0 

func _ready():
	add_to_group("zombies")
	attack_emitter.set_emitter_owner(self)
	wave_manager = get_tree().get_first_node_in_group("wave_manager")
	zombie_health_manager.max_health = zombie_health
	damage = zombie_damage
	attack_range = zombie_attack_range
	point_amount = zombie_point_amount
	ai_character_mover.move_accel = zombie_speed
	ai_timer.wait_time = randf_range(ai_timer_min_value, ai_timer_max_value)
	ai_timer.timeout.connect(_on_ai_timer_timeout)
	ai_timer.start()
	var hitboxes = find_children("Hitbox")
	for hitbox in hitboxes:
		hitbox.on_hurt.connect(zombie_health_manager.hurt)
	zombie_health_manager.gibbed.connect(queue_free)
	zombie_health_manager.died.connect(set_state.bind(STATES.DEAD))
	zombie_health_manager.damaged.connect(damage_anim)
	$RandomSoundTimer.wait_time = randi_range(15, 50)
	hitboxes.append(self)
	attack_emitter.set_bodies_to_exclude(hitboxes)
	attack_emitter.set_damage(damage)
	
	set_state(STATES.ATTACK)
		
	var rnd_size = randf_range(14.0, 17.0)
	scale = Vector3(rnd_size, rnd_size, rnd_size)
	
	var blend_param = "parameters/HurtBlend/blend_amount"
	%AnimationTree.set(blend_param, 0.0)
	
func hurt(damage_data: DamageData):
	zombie_health_manager.hurt(damage_data)

		
func set_state(state: STATES):
	if cur_state == STATES.DEAD:
		return
	cur_state = state
	match cur_state:
		STATES.IDLE:
			animation_player.play("idle")
		STATES.DEAD:
			%AnimationTree.active = false
			animation_player.play("died")
			if award_points_on_death:
				zombie_health_manager.is_award_death = award_points_on_death
				player.points += point_amount
				GameStats.add_points(point_amount)
				GameStats.add_kill()
				player.find_child("StatsDisplay").update_points_display(player.points)
				player.on_zombie_killed()
				$SmthDeathSound.play()
			died.emit(zombie_type)
			
			if wave_manager:
				wave_manager.zombie_died(zombie_type)
			collision_layer = 0
			collision_mask = 1
			ai_character_mover.stop_moving()
			var timer := Timer.new()
			add_child(timer)
			timer.wait_time = 15
			timer.one_shot = true
			timer.start()
			timer.timeout.connect(_on_death_timer_timeout)
			zombie_collision.queue_free()
			ai_timer.stop()
func _on_death_timer_timeout():
	queue_free()
	
	
func start_attack():
	animation_player.play("attack")
	
func do_attack(): #called from animation
	if player == null:
		return
	var horizontal_distance = sqrt((global_position.x - player.global_position.x) ** 2 + (global_position.z - player.global_position.z) ** 2)
	var vertical_difference = abs(global_position.y - player.global_position.y)
	if horizontal_distance <= attack_range and vertical_difference <= attack_range_vertical:
		var to_player = (player.global_position - global_position).normalized()
		var forward = -global_transform.basis.z
		if forward.dot(to_player) > 0.7:
			var damage_data = DamageData.new()
			damage_data.amount = damage
			player.hurt(damage_data)
	


func _on_random_sound_timer_timeout() -> void:
	$RandomSound.pitch_scale = randf_range(0.8, 1.5)
	$RandomSound.play
	$RandomSoundTimer.wait_time = randi_range(15, 50)
	
func damage_anim():
	var blend_param = "parameters/HurtBlend/blend_amount"
	var tree = %AnimationTree	
	if current_tween and current_tween.is_valid():
		current_tween.kill()
		tree.set(blend_param, 0.0)
	current_tween = create_tween()
	current_tween.tween_property(tree, blend_param, 0.75, 0.05)
	current_tween.tween_interval(0.2)
	current_tween.tween_property(tree, blend_param, 0.0, 0.15)

func _on_ai_timer_timeout():
	ai_timer.wait_time = randf_range(ai_timer_min_value, ai_timer_max_value)
	if cur_state == STATES.DEAD:
		return
	if cur_state == STATES.ATTACK and player:
		var attacking = animation_player.current_animation == "attack"
		var horizontal_distance = sqrt((global_position.x - player.global_position.x) ** 2 + (global_position.z - player.global_position.z) ** 2)
		var vertical_difference = abs(global_position.y - player.global_position.y)
		if horizontal_distance <= attack_range and vertical_difference <= attack_range_vertical:
			ai_character_mover.stop_moving()
			var to_player_horiz = player.global_position - global_position
			to_player_horiz.y = 0
			to_player_horiz = to_player_horiz.normalized()
			var forward_horiz = -global_transform.basis.z
			forward_horiz.y = 0
			forward_horiz = forward_horiz.normalized()
			if !attacking and forward_horiz.dot(to_player_horiz) > 0.7:
				start_attack()
		else:
			ai_character_mover.set_facing_dir(ai_character_mover.move_dir)
			ai_character_mover.move_to_point(player.global_position)
			animation_player.play("walk", -1, 1.8)
			
func set_no_points_on_death():
	award_points_on_death = false

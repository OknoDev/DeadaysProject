class_name FlyingMonster extends Monster

@export var fly_speed: float = 12.0
@export var rotation_speed: float = 8.0
@export var explosion_radius: float = 30.0
@export var health: int


@export var is_freezing: bool
@onready var collision_shape_3d: CollisionShape3D = $CollisionShape3D


var current_velocity: Vector3 = Vector3.ZERO
var target_velocity: Vector3 = Vector3.ZERO

var is_dead: bool = false

func _ready():
	
	if has_node("AICharacterMover"):
		$AICharacterMover.queue_free()
	
	if has_node("CharacterMover"):
		$CharacterMover.queue_free()
	
	if has_node("NavigationAgent3D"):
		$NavigationAgent3D.queue_free()
	
	global_position.y = -100
	
	if zombie_health_manager:

		zombie_health_manager.max_health = health
		zombie_health_manager.cur_health = health
		zombie_health_manager.is_flying = true
		zombie_health_manager.died.connect(_on_died)
		zombie_health_manager.gibbed.connect(_on_gibbed)
	var hitboxes = find_children("Hitbox")
	for hitbox in hitboxes:
		hitbox.on_hurt.connect(zombie_health_manager.hurt)
		
func _on_hit(damage_data: DamageData):
	if is_dead:
		return
	zombie_health_manager.hurt(damage_data)
		
func _on_died():
	if is_dead:
		return
	is_dead = true
	if player:
		var distance = global_position.distance_to(player.global_position)
		# Если дистанция маленькая (например, при столкновении)
		if distance < 30:
			print("Наношу урон игроку, дистанция: ", distance)
			var explosion_damage_data = DamageData.new()
			explosion_damage_data.amount = damage
			player.hurt(explosion_damage_data)
			if is_freezing:
				player.character_mover.freeze(5.0)
	
	# Останавливаем физику
	velocity = Vector3.ZERO
	if collision_shape_3d:
		collision_shape_3d.disabled = true
	
	if player:
		player.points += point_amount
		player.find_child("StatsDisplay").update_points_display(player.points)
	
	# Сообщаем WaveManager
	if wave_manager:
		wave_manager.zombie_died(zombie_type)
		
	died.emit(zombie_type)
	queue_free()
	
func _on_gibbed():
	pass
	
func _physics_process(delta):
	if not player or zombie_health_manager.cur_health <= 0:
		return
		
	if zombie_health_manager and zombie_health_manager.cur_health <= 0:
		print("FlyingMonster: здоровье 0 в physics_process, вызываю смерть")
		return

		
	var target_position = player.global_position
	
	target_position.y += 25
	
	var direction_to_player = (target_position - global_position).normalized()
	
	target_velocity = direction_to_player * fly_speed
	
	current_velocity = current_velocity.lerp(target_velocity, delta * rotation_speed)
	
	velocity = current_velocity
	
	if direction_to_player.length() > 0.1:
		var horizontal_direction = Vector3(direction_to_player.x, 0, direction_to_player.z).normalized()
		if horizontal_direction.length() > 0.1:
			# Вычисляем угол поворота
			var target_angle = atan2(-horizontal_direction.x, -horizontal_direction.z)
			# Плавный поворот
			rotation.y = lerp_angle(rotation.y, target_angle, delta * 5.0)
	
	# 6. ДВИГАЕМСЯ
	move_and_slide()
	
	if not is_dead:
		var dist = global_position.distance_to(player.global_position)
		if dist < explosion_radius:
			var dmg = DamageData.new()
			dmg.amount = 9999
			_on_hit(dmg)

	
func set_state(state: STATES):
	if state == STATES.DEAD:
		return
	super.set_state(state)
	
func hurt(damage_data: DamageData):
	_on_hit(damage_data)
		

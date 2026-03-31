extends Node3D

signal wave_started(current_wave, wave_duration, zombies_killed, is_wave_active)
signal wave_time_updated(time_remaining, total_time)
signal rest_time_updated(time_remaining)
signal wave_ended(current_wave, total_zombies_killed, wave_score)
signal zombies_count_changed(current_wave, is_wave_active, zombies_alive, zombies_killed_this_wave)
@onready var soundtrack: AudioStreamPlayer = $"../Soundtrack"
@onready var wave_start: AudioStreamPlayer = $"../WaveStart"

@onready var rest_timer: Timer = $RestTimer  # Переименуй существующий WaveTimer в RestTimer
@onready var wave_duration_timer: Timer = $WaveDurationTimer
@onready var spawn_cooldown_timer: Timer = $SpawnCooldownTimer

@export var player: CharacterBody3D
@export var rest_time = 25.0

@export var wave_duration_base: float = 60.0  # 60 секунд для первой волны
@export var wave_duration_increase: float = 10.0  # Каждая следующая волна +10 секунд
@export var max_zombies_on_scene: int = 25
@export var spawn_cooldown_min: float = 0.5  # Минимальная задержка между спавнами
@export var spawn_cooldown_max: float = 2.0  # Максимальная задержка между спавнами

@export var normal_zombie_scene: PackedScene
@export var fast_zombie_scene: PackedScene
@export var heavy_zombie_scene: PackedScene
@export var skull_zombie_scene: PackedScene
@export var ice_skull_zombie_scene: PackedScene

@export_category("Zombie Spawn Probabilities")
@export var normal_probability_base: float = 100.0  # 100% на первой волне
@export var fast_probability_base: float = 0.0      # 0% на первой волне  
@export var heavy_probability_base: float = 0.0
@export var skull_probability_base: float = 0.0
@export var ice_skull_probability_base: float = 0.0

@export var probability_change_per_wave: float = 15.0

var current_wave: int = 0
var is_wave_active: bool  = false
var is_rest_period: bool = true
var wave_time_remaining: float = 0.0
var total_wave_time: float = 0.0

var zombies_alive: int = 0
var zombies_killed_this_wave: int = 0
var zombies_killed_total: int = 0

var spawners = []
var zombie_spawn_weights: Dictionary = {}


func _ready():
	
	add_to_group("wave_manager")
	
	# Подключаем таймеры
	if rest_timer:
		rest_timer.timeout.connect(_on_rest_timer_timeout)

	
	if wave_duration_timer:
		wave_duration_timer.timeout.connect(_on_wave_duration_timer_timeout)

	
	if spawn_cooldown_timer:
		spawn_cooldown_timer.timeout.connect(_on_spawn_cooldown_timeout)

	# НЕ ждем 2 секунды - начинаем сразу тест
	start_wave()
	
func register_spawner(spawner):
	spawners.append(spawner)

func start_wave():
	current_wave += 1
	is_wave_active = true
	is_rest_period = false
	
	zombies_killed_this_wave = 0
	zombies_alive = 0
	GameStats.record_wave(current_wave)
	update_spawn_probabilities()
	
	total_wave_time = wave_duration_base + (current_wave - 1) * wave_duration_increase
	wave_time_remaining = total_wave_time
	
	soundtrack.volume_db = -6
	
	player.hide_shop()
	wave_start.play()
	

	wave_duration_timer.start(total_wave_time)

	wave_duration_timer.start(total_wave_time)
	_on_spawn_cooldown_timeout()
	emit_signal("wave_started", current_wave, total_wave_time, zombies_killed_this_wave, is_wave_active)
	emit_signal("zombies_count_changed", current_wave, is_wave_active, zombies_alive, zombies_killed_this_wave)
	
func update_spawn_probabilities():
	var wave_factor = current_wave - 1
	var normal_prob = max(normal_probability_base - (wave_factor * probability_change_per_wave), 10.0)
	
	var fast_prob = fast_probability_base + (wave_factor * 8.0)
	var heavy_prob = heavy_probability_base + (wave_factor * 6.0)
	var skull_prob = skull_probability_base + (wave_factor * 5.0)
	var ice_skull_prob = ice_skull_probability_base + (wave_factor * 4.0)
	
	fast_prob = clamp(fast_prob, 0.0, 70)
	heavy_prob = clamp(heavy_prob, 0.0, 60.0)
	skull_prob = clamp(skull_prob, 0.0, 50.0)
	ice_skull_prob = clamp(ice_skull_prob, 0.0, 40.0)
	zombie_spawn_weights = {
		"normal": normal_prob,
		"fast": fast_prob,
		"heavy": heavy_prob,
		"skull": skull_prob,
		"ice_skull": ice_skull_prob
	}
	var total = 0.0
	for weight in zombie_spawn_weights.values():
		total += weight
	for key in zombie_spawn_weights.keys():
		zombie_spawn_weights[key] = (zombie_spawn_weights[key] / total) * 100.0
	for spawner in spawners:
		spawner.set_spawn_probabilities(zombie_spawn_weights)
		
func end_wave():
	if not is_wave_active:
		return
	is_wave_active = false
	spawn_cooldown_timer.stop()
	kill_all_zombies()

	soundtrack.volume_db = -12
	emit_signal("wave_ended", current_wave, zombies_killed_this_wave, 0)
	emit_signal("zombies_count_changed", current_wave, is_wave_active, zombies_alive, zombies_killed_this_wave)
	start_rest_period()
	
func kill_all_zombies():
	var zombies = get_tree().get_nodes_in_group("zombies")
	for zombie in zombies:
		if zombie.has_method("set_no_points_on_death"):
			zombie.set_no_points_on_death()
		if zombie.has_method("hurt"):
			var damage_data = DamageData.new()
			damage_data.amount = 999
			zombie.hurt(damage_data)
	zombies_alive = 0
	emit_signal("zombies_count_changed", current_wave, is_wave_active, zombies_alive, zombies_killed_this_wave)


func start_rest_period():
	is_rest_period = true
	rest_timer.wait_time = rest_time
	rest_timer.start()
	
func report_zombie_spawned():
	zombies_alive += 1
	emit_signal("zombies_count_changed", current_wave, is_wave_active, zombies_alive, zombies_killed_this_wave)




func _on_rest_timer_timeout():
	if is_rest_period and not is_wave_active:
		start_wave()

func _on_wave_duration_timer_timeout():
	if is_wave_active:
		end_wave()
	
func _on_spawn_cooldown_timeout():
	if not is_wave_active or zombies_alive >= max_zombies_on_scene:
		return
	
	# Находим спавнер, который может заспавнить зомби
	var available_spawners = []
	for spawner in spawners:
		if spawner.is_active:
			available_spawners.append(spawner)
	
	
	if available_spawners.size() > 0:
		# Выбираем случайный спавнер
		var spawner = available_spawners[randi() % available_spawners.size()]
		spawner.spawn_random_zombie()
	
	# Планируем следующий спавн
	spawn_cooldown_timer.wait_time = randf_range(spawn_cooldown_min, spawn_cooldown_max)
	spawn_cooldown_timer.start()

func _process(delta):
	if is_wave_active:
		wave_time_remaining = wave_duration_timer.time_left
		emit_signal("wave_time_updated", wave_time_remaining, total_wave_time)
	elif is_rest_period and rest_timer and rest_timer.is_inside_tree():
		var rest_time_left = rest_timer.time_left
		emit_signal("rest_time_updated", rest_time_left)

func zombie_died(zombie_type: String = "normal"):
	zombies_alive -= 1
	zombies_killed_this_wave += 1
	emit_signal("zombies_count_changed", current_wave, is_wave_active, zombies_alive, zombies_killed_this_wave)

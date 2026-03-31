extends Node3D

signal wave_started(current_wave, wave_duration, zombies_killed, is_wave_active)
signal wave_time_updated(time_remaining, total_time)
signal wave_ended(current_wave, total_zombies_killed, wave_score)
signal zombies_count_changed(zombies_alive, zombies_killed_this_wave)

@onready var wave_start: AudioStreamPlayer = $"../WaveStart"
var current_wave = 0
var zombies_amnt = 0
var zombies_alive = 0
var is_wave_active = false
var spawners = []
var max_zombie_on_scene = 10
@onready var wave_timer: Timer = $WaveTimer
var rest_time = 15.0
var zombies_spawned = 0 
var fast_zombies_amnt = 0
@export var player: CharacterBody3D

var total_enemies = zombies_amnt + fast_zombies_amnt

func _ready():
	wave_timer.wait_time = rest_time
	wave_timer.start()
	start_next_wave()

func register_spawner(spawner):
	spawners.append(spawner)

func start_next_wave():
	current_wave += 1
	is_wave_active = true
	player.hide_shop()

	wave_start.play()
	# Расчет общего количества зомби для волны
	zombies_amnt = current_wave
	if current_wave > 2:
		fast_zombies_amnt = (current_wave - 2)
	else:
		fast_zombies_amnt = 0
		
	zombies_alive = 0
	zombies_spawned = 0
	
	total_enemies = zombies_amnt + fast_zombies_amnt
	emit_signal("wave_started", current_wave, is_wave_active, zombies_alive)
	
	# Активируем все спавнеры
	for spawner in spawners:
		spawner.start_wave(zombies_amnt, fast_zombies_amnt)

func report_zombie_spawned(is_fast: bool = false):
	zombies_alive += 1
	zombies_spawned += 1
	if is_fast:
		fast_zombies_amnt -= 1
	
func report_zombie_died():
	zombies_alive -= 1
	total_enemies = zombies_amnt + fast_zombies_amnt
	emit_signal("zombies_count_changed", current_wave, is_wave_active, zombies_alive)
	# Проверка завершения волны
	if is_wave_active && zombies_alive == 0 && zombies_spawned >= total_enemies:
		end_wave()

func end_wave():
	is_wave_active = false
	total_enemies = zombies_amnt + fast_zombies_amnt
	emit_signal("wave_ended", current_wave, is_wave_active, zombies_alive)
	wave_timer.wait_time = rest_time
	wave_timer.start()


func _on_wave_timer_timeout() -> void:
	if !is_wave_active:
		start_next_wave()

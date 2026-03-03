extends Control
@onready var wave_progress_bar: TextureProgressBar = $WaveProgressBar
@onready var wave_label: Label = $WaveLabel
@onready var health_bar: TextureProgressBar = $HealthBar
@onready var health_label: Label = $HealthBar/HealthLabel
@onready var ammo_bar: TextureProgressBar = $AmmoBar
@onready var ammo_label: Label = $AmmoBar/AmmoLabel
@onready var health_manager: Node3D = %HealthManager
@onready var weapon_manager: Node3D = %WeaponManager
@onready var wave_manager = get_tree().get_first_node_in_group("wave_manager")
@onready var point_label: Label = $PointLabel
@onready var blood_screen: TextureRect = $BloodScreen
@onready var wave_timer_label: Label = $TimerLabel


func _ready():
	wave_manager.zombies_count_changed.connect(update_wave_display)
	update_points_display(0)
	wave_manager.wave_started.connect(update_wave_display)
	wave_manager.wave_ended.connect(update_wave_display)
	wave_manager.wave_time_updated.connect(update_wave_timer_display)
	health_manager.health_change.connect(update_health_display)
	
	if wave_manager.is_wave_active:
		# Если волна уже активна, показываем таймер
		update_wave_timer_display(wave_manager.wave_time_remaining, wave_manager.total_wave_time)
	else:
		# Если отдых, скрываем или показываем что-то другое
		wave_timer_label.text = ""
		
	for weapon in weapon_manager.weapons:
		weapon.ammo_updated.connect(update_ammo_display)
	#update_health_display(health_manager.cur_health, health_manager.max_health)
	update_ammo_display(weapon_manager.cur_weapon.ammo, weapon_manager.cur_weapon.max_ammo)
	update_wave_display(wave_manager.current_wave, wave_manager.is_wave_active, 0, wave_manager.zombies_alive)

func update_health_display(cur_health: int, max_health: int):
	var alpha = 1.0 - (cur_health / float(max_health))
	blood_screen.modulate.a = lerp(blood_screen.modulate.a, alpha, 1.0)
	health_bar.max_value = max_health
	health_bar.value = cur_health
	health_label.text = "%s" % cur_health


	
	
func update_ammo_display(ammo_amnt: int, max_ammo: int):
	if ammo_amnt < 0:
		ammo_label.text = "Knife"
	else:
		ammo_label.text = "%s" % ammo_amnt
	ammo_bar.max_value = max_ammo
	ammo_bar.value = ammo_amnt

func update_wave_display(number_of_wave: int, is_wave_active: bool, total_enemies: int, zombies_alive: int):
	if is_wave_active:
		wave_label.text = tr("WAVE") % number_of_wave
		wave_progress_bar.value = zombies_alive
		wave_timer_label.visible = true
	else:
		wave_label.text = tr("REST")
		wave_timer_label.modulate = Color.WHITE
		
func update_points_display(point_amnt: int):
	point_label.text = tr("POINTS") % point_amnt

func update_wave_timer_display(time_remaining: float, total_time: float):
	# Конвертируем секунды в минуты:секунды
	var minutes = int(time_remaining) / 60
	var seconds = int(time_remaining) % 60
	
	# Форматируем строку (например: "01:30")
	wave_timer_label.text = "%02d:%02d" % [minutes, seconds]
	
	# Дополнительно: меняем цвет при низком времени
	if time_remaining < 10.0:  # Меньше 10 секунд
		wave_timer_label.modulate = Color(0.9, 0.0, 0.15, 1.0)
	elif time_remaining < 30.0:  # Менее 30 секунд
		wave_timer_label.modulate = Color(1.0, 0.65, 0.0, 1.0)
	else:
		wave_timer_label.modulate = Color.WHITE
	

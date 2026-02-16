extends Node

# Автозагружаемый скрипт для управления настройками
const SETTINGS_PATH = "user://game_settings.cfg"

# Значения по умолчанию
var FOV: int = 75
var mouse_sense: float = 1.0
var master_volume: float = 0.8
var music_volume: float = 0.7
var player_volume: float = 1.0
var zombie_volume: float = 1.0
var shooting_volume: float = 1.0
var limit_FPS: int = 60
var crosshair_visible: bool = true

func _ready():
	load_settings()

# Сохранение всех настроек в файл
func save_settings():
	var config = ConfigFile.new()
	
	config.set_value("video", "fov", FOV)
	config.set_value("video", "limit_fps", limit_FPS)
	config.set_value("video", "crosshair_visible", crosshair_visible)
	config.set_value("controls", "mouse_sense", mouse_sense)
	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "player_volume", player_volume)
	config.set_value("audio", "zombie_volume", zombie_volume)
	config.set_value("audio", "shooting_volume", shooting_volume)
	var error = config.save(SETTINGS_PATH)
	if error != OK:
		push_error("Ошибка сохранения настроек: " + str(error))

# Загрузка настроек из файла
func load_settings():
	var config = ConfigFile.new()
	var error = config.load(SETTINGS_PATH)
	
	if error == OK:  # Файл найден
		FOV = config.get_value("video", "fov", 75)
		limit_FPS = config.get_value("video", "limit_fps", 60)
		crosshair_visible = config.get_value("video", "crosshair_visible", true)
		mouse_sense = config.get_value("controls", "mouse_sense", 1.0)
		master_volume = config.get_value("audio", "master_volume", 0.8)
		music_volume = config.get_value("audio", "music_volume", 0.7)
		player_volume = config.get_value("audio", "player_volume", 1.0)
		zombie_volume = config.get_value("audio", "zombie_volume", 1.0)
		shooting_volume = config.get_value("audio", "shooting_volume", 1.0)
		Engine.max_fps = limit_FPS
	else:  # Файл не найден, используем значения по умолчанию
		save_settings()
	
	# Применяем настройки сразу после загрузки
	apply_audio_settings()

func to_db(linear: float) -> float:
	if linear <= 0.0001:
		return -80
	var curved = pow(linear, 2.0)
	return linear_to_db(curved)
		

func apply_audio_settings():

	AudioServer.set_bus_volume_db(0, to_db(master_volume))
	AudioServer.set_bus_volume_db(1, to_db(music_volume))
	AudioServer.set_bus_volume_db(2, to_db(player_volume))
	AudioServer.set_bus_volume_db(3, to_db(zombie_volume))
	AudioServer.set_bus_volume_db(4, to_db(shooting_volume))
	

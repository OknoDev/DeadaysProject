extends Node

var current_wave: int = 0
var total_kills: int = 0
var total_points: int = 0
var play_time: float = 0.0

var high_scores: Dictionary = {}
var current_mode: String = "normal"
func _ready():
	load_high_scores()

func start_new_game(mode: String = "normal"):
	reset_session()

func reset_session():
	current_wave = 0
	total_kills = 0
	total_points = 0
	play_time = 0.0

func record_wave(wave: int):
	current_wave = wave

func add_kill():
	total_kills += 1
	
func add_points(amount: int):
	total_points += amount

func update_time(delta):
	play_time += delta

func end_game():
	var mode = "normal"
	if not high_scores.has(mode):
		high_scores[mode] = {"wave": 0, "points": 0, "kills": 0}
	var best = high_scores[mode]
	if current_wave > best.wave:
		best.wave = current_wave
	if total_points > best.points:
		best.points = total_points
	if total_kills > best.kills:
		best.kills = total_kills
	save_high_scores()

func save_high_scores():
	var file = FileAccess.open("user://high_scores.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(high_scores))
	
func load_high_scores():
	if FileAccess.file_exists("user://high_scores.json"):
		var file = FileAccess.open("user://high_scores.json", FileAccess.READ)
		var content = file.get_as_text()
		high_scores = JSON.parse_string(content)
		if high_scores == null:
			high_scores = {}
			

func clear_high_scores():
	high_scores = {}
	save_high_scores()

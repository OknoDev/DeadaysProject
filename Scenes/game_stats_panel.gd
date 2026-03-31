extends Control
@onready var wave_label: Label = $ColorRect/VBoxContainer/WaveLabel
@onready var kills_label: Label = $ColorRect/VBoxContainer/KillsLabel
@onready var points_label: Label = $ColorRect/VBoxContainer/PointsLabel
@onready var time_label: Label = $ColorRect/VBoxContainer/TimeLabel

@onready var record_wave_label: Label = $RecordColorRect/RecordVBoxContainer/RecordWaveLabel
@onready var record_kills_label: Label = $RecordColorRect/RecordVBoxContainer/RecordKillsLabel
@onready var record_points_label: Label = $RecordColorRect/RecordVBoxContainer/RecordPointsLabel

func _ready():
	update_stats()

func update_stats():
	var stats = GameStats
	var mode = stats.current_mode
	var best = stats.high_scores.get(mode, {"wave": 0, "kills": 0, "points": 0})
	wave_label.text = tr("WAVE_STATS") % stats.current_wave
	kills_label.text = tr("KILLS_STATS") % stats.total_kills
	points_label.text = tr("POINTS_STATS") % stats.total_points
	var time_seconds = int(stats.play_time)
	var minutes = time_seconds / 60
	var seconds = time_seconds % 60
	time_label.text = tr("TIME_STATS") % [minutes, seconds]
	
	record_wave_label.text = tr("WAVE_STATS") % int(best.wave)
	record_kills_label.text = tr("KILLS_STATS") % int(best.kills)
	record_points_label.text = tr("POINTS_STATS") % int(best.points)
	
	if stats.total_points >= best.points:
		points_label.modulate = Color(1.0, 0.78, 0.0)
	else:
		points_label.modulate = Color.WHITE
	if stats.total_kills > best.kills:
		kills_label.modulate = Color(1.0, 0.78, 0.0)
	else:
		points_label.modulate = Color.WHITE
	if stats.current_wave > best.wave:
		wave_label.modulate = Color(1.0, 0.78, 0.0)
	else:
		points_label.modulate = Color.WHITE

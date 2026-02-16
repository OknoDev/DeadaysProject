extends Control
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var button: Button = $Restart/Button
@onready var stats_display: Control = $"../StatsDisplay"
@onready var you_lose_label: Label = $YouLoseLabel

@export var lose_phrases = []
func _ready():
	button.button_up.connect(restart_level)
	hide()
	
func show_death_screen():
	you_lose_label.text = lose_phrases[randi_range(0, 8)]
	stats_display.hide()
	animation_player.play("intro")
	show()
	await animation_player.animation_finished
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	pass
	
func restart_level():
	get_tree().reload_current_scene()
	pass

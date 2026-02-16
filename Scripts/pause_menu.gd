extends Control
@onready var label_1: Label = $ColorRect/ToMenuLabel
@onready var label_2: Label = $ColorRect/SettingsLabel
@onready var label_3: Label = $ColorRect/ContinueLabel
@onready var stats_display: Control = $"../StatsDisplay"
@onready var knp_click: AudioStreamPlayer = $KnpClick
@onready var character_mover: CharacterMover = $"../../../../CharacterMover"
@onready var settings_menu: Control = $"../SettingsMenu"

func _on_to_menu_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/mainmenu.tscn")
	pass




func _on_continue_button_pressed() -> void:
	hide()
	stats_display.show()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	character_mover.move_accel = 8
	get_tree().paused = false




func _on_settings_button_mouse_exited() -> void:
	label_2.label_settings.font_color = Color(1, 1, 1, 1)



func _on_settings_mouse_entered() -> void:
	label_2.label_settings.font_color = Color(0.65, 0.65, 0.65, 1)
	knp_click.play()


func _on_to_menu_mouse_entered() -> void:
	label_1.label_settings.font_color = Color(0.65, 0.65, 0.65, 1)
	knp_click.play()


func _on_to_menu_mouse_exited() -> void:
	label_1.label_settings.font_color = Color(1, 1, 1, 1)


func _on_continue_mouse_entered() -> void:
	label_3.label_settings.font_color = Color(0.65, 0.65, 0.65, 1)
	knp_click.play()


func _on_continue_mouse_exited() -> void:
	label_3.label_settings.font_color = Color(1, 1, 1, 1)


func _on_settings_button_pressed() -> void:
	hide()
	settings_menu.show()

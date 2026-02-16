extends Control
@onready var start_button: Button = $ColorRect/StartButton
@onready var exit_button: Button = $ColorRect/ExitButton
@onready var knp_click: AudioStreamPlayer = $KnpClick
@onready var start_label: Label = $ColorRect/StartButton/StartLabel
@onready var label_2: Label = $ColorRect/ExitButton/Label2
@onready var settings_label: Label = $ColorRect/SettingsButton/SettingsLabel

@onready var settings_menu: Control = $"../SettingsMenu"


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/world.tscn")
	pass # Replace with function body.


func _on_exit_button_pressed() -> void:
	get_tree().quit()
	pass # Replace with function body.


func _on_start_button_mouse_entered() -> void:
	start_label.label_settings.font_color = Color(0.65, 0.65, 0.65, 1)
	print("start")
	knp_click.play()


func _on_start_button_mouse_exited() -> void:
	start_label.label_settings.font_color = Color(1, 1, 1, 1)


func _on_exit_button_mouse_entered() -> void:
	label_2.label_settings.font_color = Color(0.65, 0, 0, 1)
	knp_click.play()


func _on_exit_button_mouse_exited() -> void:
	label_2.label_settings.font_color = Color(0.74, 0.03, 0.17, 1)



func _on_settings_button_pressed() -> void:
	hide()
	settings_menu.show()


func _on_settings_button_mouse_entered() -> void:
	settings_label.label_settings.font_color = Color(0.65, 0.65, 0.65, 1)
	print("settings")
	knp_click.play()


func _on_settings_button_mouse_exited() -> void:
	settings_label.label_settings.font_color = Color(1, 1, 1, 1)

extends ColorRect

var is_russian = true

func _on_button_pressed() -> void:
	is_russian = !is_russian
	if is_russian:
		TranslationServer.set_locale("ru")
		$Button/Label.text = "RU"  # или "Switch to English"
	else:
		TranslationServer.set_locale("en")
		$Button/Label.text = "EN"

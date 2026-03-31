extends Node

enum GameMode {
	CLASSIC,           # Классический
	FLOOR_IS_LAVA    # Пол - это лава
}

var current_mode: GameMode = GameMode.CLASSIC
var is_lava_mode: bool = false

func set_game_mode(mode: GameMode):
	current_mode = mode
	is_lava_mode = (mode == GameMode.FLOOR_IS_LAVA)

	# Сообщаем другим системам о смене режима
	get_tree().call_group("game_mode_listeners", "_on_game_mode_changed", mode)

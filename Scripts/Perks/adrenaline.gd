extends Perk
class_name Adrenaline

func apply(player: Node, weapon: Node = null) -> void:
	if player and player.has_method("start_adrenaline_regen"):
		player.start_adrenaline_regen()

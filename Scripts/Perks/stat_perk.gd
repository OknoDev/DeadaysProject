extends Perk
class_name StatPerk

func apply(player: Node, weapon: Node = null) -> void:
	if weapon:
		weapon.apply_modifiers(modifiers)
	elif perk_type == 0 and player.has_methond("apply_character_modifiers"):
		player.apply_character_modifiers(modifiers)

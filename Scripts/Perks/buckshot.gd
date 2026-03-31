extends Perk
class_name Buckshot

func apply(player: Node, weapon: Node = null) -> void:
	if weapon and weapon.has_method("set_buckshot_active"):
		weapon.set_buckshot_active(true)

extends Perk
class_name TrophyAmmo

func apply(player: Node, weapon: Node = null) -> void:
	if weapon and weapon.has_method("set_trophy_ammo_active"):
		weapon.set_trophy_ammo_active(true)

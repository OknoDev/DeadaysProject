extends Perk
class_name Anatomy

func apply(player: Node, weapon: Node = null) -> void:

	if weapon and weapon.has_method("set_anatomy_active"):

		weapon.set_anatomy_active(true)

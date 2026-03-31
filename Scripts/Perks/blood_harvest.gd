extends Perk
class_name BloodHarvest

func apply(player: Node, weapon: Node = null) -> void:
	if player and player.has_method("set_blood_harvest_active"):
		player.set_blood_harvest_active(true)

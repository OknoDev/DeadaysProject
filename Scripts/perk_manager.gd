extends Node

signal perk_bought(perk: Perk)
@export var all_perks: Array[Perk] = []

var bought_perks: Dictionary = {}

func get_player():
	return get_tree().get_first_node_in_group("player")
	
func buy_perk(perk: Perk) -> bool:
	var player = get_player()
	if not player:
		return false
	var path = perk.resource_path
	if bought_perks.has(path):
		return false
	if player.points < perk.price:
		return false
	player.points -= perk.price
	player.stats_display.update_points_display(player.points)
	player.shop_menu.update_points_shop_display(player.points)
	bought_perks[path] = true
	perk_bought.emit(perk)
	perk.apply(player, player.weapon_manager.cur_weapon)
	return true

func is_perk_bought(perk: Perk) -> bool:
	return bought_perks.has(perk.resource_path)

func get_modifiers_for_type(perk_type: int) -> Dictionary:
	var total = {}
	for path in bought_perks:
		var perk = load(path) as Perk
		if perk.perk_type == perk_type:
			for key in perk.modifiers:
				total[key] - total.get(key, 0) + perk.modifiers[key]
	return total

func reset_perks():
	bought_perks.clear()
	perk_bought.emit(null) 

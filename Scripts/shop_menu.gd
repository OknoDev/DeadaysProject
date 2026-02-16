extends Control
@export var player: CharacterBody3D
@export var weapon_manager: Node3D
@onready var buying: AudioStreamPlayer = $ShopColor/Container/Buying
@onready var stats_display: Control = $"../StatsDisplay"
@onready var point_label: Label = $ShopColor/PointLabel
@onready var makarov: Weapon = $"../../WeaponManager/Weapons/Makarov"
@onready var shotgun: Weapon = $"../../WeaponManager/Weapons/Shotgun"
@onready var m_4a_1: Weapon = $"../../WeaponManager/Weapons/M4A1"
@onready var shotgunlabel: Label = $ShopColor/Container/ShotgunSlot/Label
@onready var m4label: Label = $ShopColor/Container/M4Slot/Label
@onready var pistol_upgrades: Control = $ShopColor/Container/PistolUpgrades
@onready var shotgun_upgrades: Control = $ShopColor/Container/ShotgunUpgrades
@onready var m_4_upgrades: Control = $ShopColor/Container/M4Upgrades
@onready var stats_point_label: Label = $"../StatsDisplay/PointLabel"

var select_color = Color(0.27, 0.1, 0, 1)
var normal_color = Color(0, 0, 0, 0.61)

var upgrade_damage_makarov_price = 100
var upgrade_damage_m4a1_price = 150
var upgrade_damage_shotgun_price = 100

var upgrade_damage_makarov_level = 0
var upgrade_damage_m4a1_level = 0
var upgrade_damage_shotgun_level = 0

var upgrade_ammo_makarov_price = 150
var upgrade_ammo_m4a1_price = 200
var upgrade_ammo_shotgun_price = 100

var upgrade_ammo_makarov_level = 0
var upgrade_ammo_m4a1_level = 0
var upgrade_ammo_shotgun_level = 0

func mouse_entered():
	pass

func mouse_exited():
	pass

func update_points_shop_display(point_amnt: int):
	point_label.text = ("Очки: %s" % point_amnt)
	stats_point_label.text = ("Очки: %s" % point_amnt)
func _on_m4a1_button_pressed() -> void:
	if !weapon_manager.weapons_unlocked[2] && player.points >= 100:
		player.points -= 100
		weapon_manager.weapons_unlocked[2] = true
		update_points_shop_display(player.points)
		buying.play()
		m4label.hide()
	if weapon_manager.weapons_unlocked[2]:
		$ShopColor/Container/ShotgunSlot.color = normal_color
		$ShopColor/Container/M4Slot.color = select_color
		$ShopColor/Container/PistolSlot.color = normal_color
		m_4_upgrades.show()
		shotgun_upgrades.hide()
		pistol_upgrades.hide()


func _on_shotgun_button_pressed() -> void:
	if !weapon_manager.weapons_unlocked[3] && player.points >= 120:
		player.points -= 120
		weapon_manager.weapons_unlocked[3] = true
		update_points_shop_display(player.points)
		buying.play()
		shotgunlabel.hide()
	if weapon_manager.weapons_unlocked[3]:
		$ShopColor/Container/ShotgunSlot.color = select_color
		$ShopColor/Container/M4Slot.color = normal_color
		$ShopColor/Container/PistolSlot.color = normal_color
		shotgun_upgrades.show()
		m_4_upgrades.hide()
		pistol_upgrades.hide()



func _on_ammo_button_pressed() -> void:
	if player.points >= 45 && weapon_manager.weapons_unlocked[2] && m_4a_1.ammo < m_4a_1.max_ammo:
		player.points -= 45
		m_4a_1.add_ammo(30)
		update_points_shop_display(player.points)
		buying.play()
		

func _on_shotgun_ammo_button_pressed() -> void:
	if player.points >= 50  && weapon_manager.weapons_unlocked[3] && shotgun.ammo < shotgun.max_ammo:
		player.points -= 50
		shotgun.add_ammo(15)
		update_points_shop_display(player.points)
		buying.play()


func _on_makarov_ammo_button_pressed() -> void:
	if player.points >= 30 && makarov.ammo < makarov.max_ammo:
		player.points -= 30
		makarov.add_ammo(30)
		update_points_shop_display(player.points)
		buying.play()


func _on_pistol_button_pressed() -> void:
	$ShopColor/Container/ShotgunSlot.color = normal_color
	$ShopColor/Container/M4Slot.color = normal_color
	$ShopColor/Container/PistolSlot.color = select_color
	pistol_upgrades.show()
	m_4_upgrades.hide()
	shotgun_upgrades.hide()

	


func _on_upgrade_damage_makarov_button_pressed() -> void:
	if player.points >= upgrade_damage_makarov_price && upgrade_damage_makarov_level < 5:
		player.points -= upgrade_damage_makarov_price
		makarov.damage_multiply += 0.25
		makarov.update_damage()
		upgrade_damage_makarov_price *= 1.5
		upgrade_damage_makarov_level += 1
		update_points_shop_display(player.points)
		$ShopColor/Container/PistolUpgrades/TextureProgressBar/UpgradeButtonColor/PriceLabel.text = "%s" % upgrade_damage_makarov_price
		$ShopColor/Container/PistolUpgrades/TextureProgressBar.value = upgrade_damage_makarov_level
		buying.play()


func _on_upgrade_ammo_makarov_button_pressed() -> void:
	if player.points >= upgrade_ammo_makarov_price && upgrade_ammo_makarov_level < 5:
		player.points -= upgrade_ammo_makarov_price
		makarov.max_ammo += 5
		stats_display.update_ammo_display(weapon_manager.cur_weapon.ammo,weapon_manager.cur_weapon.max_ammo )
		upgrade_ammo_makarov_price *= 1.5
		upgrade_ammo_makarov_level += 1
		update_points_shop_display(player.points)
		$ShopColor/Container/PistolUpgrades/AmmoAmountBar/UpgradeButtonColor/PriceLabel.text = "%s" % upgrade_ammo_makarov_price
		$ShopColor/Container/PistolUpgrades/AmmoAmountBar.value = upgrade_damage_makarov_level
		buying.play()

func _on_upgrade_damage_m4_button_pressed():
	if player.points >= upgrade_damage_m4a1_price && upgrade_damage_m4a1_level < 5:
		player.points -= upgrade_damage_m4a1_price
		m_4a_1.damage_multiply += 0.25
		m_4a_1.update_damage()
		upgrade_damage_m4a1_price *= 1.5
		upgrade_damage_m4a1_level += 1
		update_points_shop_display(player.points)
		$ShopColor/Container/M4Upgrades/TextureProgressBar/UpgradeButtonColor/PriceLabel.text = "%s" % upgrade_damage_m4a1_price
		$ShopColor/Container/M4Upgrades/TextureProgressBar.value = upgrade_damage_m4a1_level
		buying.play()

func _on_upgrade_ammo_m4_button_pressed():
	if player.points >= upgrade_ammo_m4a1_price && upgrade_ammo_m4a1_level < 5:
		player.points -= upgrade_ammo_m4a1_price
		m_4a_1.max_ammo += 5
		stats_display.update_ammo_display(weapon_manager.cur_weapon.ammo,weapon_manager.cur_weapon.max_ammo )
		upgrade_ammo_m4a1_price *= 1.5
		upgrade_ammo_m4a1_level += 1
		update_points_shop_display(player.points)
		$ShopColor/Container/M4Upgrades/AmmoAmountBar/UpgradeButtonColor/PriceLabel.text = "%s" % upgrade_damage_m4a1_price
		$ShopColor/Container/M4Upgrades/AmmoAmountBar.value = upgrade_damage_makarov_level
		buying.play()
	
func _on_upgrade_damage_shotgun_button_pressed():
	if player.points >= upgrade_damage_shotgun_price && upgrade_damage_shotgun_level < 5:
		player.points -= upgrade_damage_shotgun_price
		shotgun.damage_multiply += 0.25
		shotgun.update_damage()
		upgrade_damage_shotgun_price *= 1.5
		upgrade_damage_shotgun_level += 1
		update_points_shop_display(player.points)
		$ShopColor/Container/ShotgunUpgrades/TextureProgressBar/UpgradeButtonColor/PriceLabel.text = "%s" %  upgrade_damage_shotgun_price
		$ShopColor/Container/ShotgunUpgrades/TextureProgressBar.value = upgrade_damage_shotgun_level
		buying.play()
		
func _on_upgrade_ammo_shotgun_button_pressed():
	if player.points >= upgrade_ammo_shotgun_price && upgrade_ammo_shotgun_level < 5:
		player.points -= upgrade_ammo_shotgun_price
		shotgun.max_ammo += 5
		stats_display.update_ammo_display(weapon_manager.cur_weapon.ammo,weapon_manager.cur_weapon.max_ammo)
		upgrade_ammo_shotgun_price *= 1.5
		upgrade_ammo_shotgun_level += 1
		update_points_shop_display(player.points)
		$ShopColor/Container/M4Upgrades/AmmoAmountBar/UpgradeButtonColor/PriceLabel.text = "%s" % upgrade_ammo_shotgun_price
		$ShopColor/Container/ShotgunUpgrades/AmmoAmountBar.value = upgrade_ammo_shotgun_level
		buying.play()

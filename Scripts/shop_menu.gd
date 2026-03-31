extends Control

@export var player: CharacterBody3D
@export var weapon_manager: Node3D

@onready var buying_sound: AudioStreamPlayer = $ShopColor/Container/Buying
@onready var point_label: Label = $ShopColor/PointLabel
@onready var stats_point_label: Label = $"../StatsDisplay/PointLabel"

@onready var player_panel: Control = $ShopColor/Container/PlayerUpgrades
@onready var knife_panel: Control = $ShopColor/Container/KnifeUpgrades
@onready var pistol_panel: Control = $ShopColor/Container/PistolUpgrades
@onready var m16_panel: Control = $ShopColor/Container/M16Upgrades

@onready var shotgun_panel: Control = $ShopColor/Container/ShotgunUpgrades
@onready var pistol_weapon = $"../../WeaponManager/Weapons/Makarov"
@onready var shotgun_weapon = $"../../WeaponManager/Weapons/Shotgun"
@onready var m4a1_weapon = $"../../WeaponManager/Weapons/M4A1"

@onready var perk_desc_background: ColorRect = %PerkDescBackground

@onready var icon = %Icon
@onready var name_label = %NameLabel
@onready var desc_label = %DescLabel

@onready var stats_display: Control = $"../StatsDisplay"

var select_color = Color(0.27, 0.1, 0, 1)
var normal_color = Color(0, 0, 0, 0.61)



func update_perk_info(perk: Perk):
	if perk_desc_background:
		perk_desc_background.show()
	if icon and perk.icon:
		icon.texture = perk.icon
	if name_label and desc_label:
		name_label.text = tr(perk.name_key)
		desc_label.text = tr(perk.desc_key)
	
func clear_perk_info():
	perk_desc_background.hide()
	
func update_points_shop_display(point_amnt: int):
	point_label.text = tr("POINTS") % point_amnt
	stats_point_label.text = tr("POINTS") % point_amnt
	
func _on_m4a1_button_pressed() -> void:
	if !weapon_manager.weapons_unlocked[2] && player.points >= 300:
		player.points -= 300
		weapon_manager.weapons_unlocked[2] = true
		update_points_shop_display(player.points)
		buying_sound.play()
		$ShopColor/Container/M16Slot/Label.hide()
	if weapon_manager.weapons_unlocked[2]:
		$ShopColor/Container/ShotgunSlot.color = normal_color
		$ShopColor/Container/M16Slot.color = select_color
		$ShopColor/Container/PistolSlot.color = normal_color
		$ShopColor/Container/KnifeSlot.color = normal_color
		$ShopColor/Container/PlayerSlot.color = normal_color
		show_panel(m16_panel)
	clear_perk_info()
	
func _on_shotgun_button_pressed() -> void:
	if !weapon_manager.weapons_unlocked[3] && player.points >= 250:
		player.points -= 250
		weapon_manager.weapons_unlocked[3] = true
		update_points_shop_display(player.points)
		buying_sound.play()
		$ShopColor/Container/ShotgunSlot/Label.hide()
	if weapon_manager.weapons_unlocked[3]:
		$ShopColor/Container/ShotgunSlot.color = select_color
		$ShopColor/Container/M16Slot.color = normal_color
		$ShopColor/Container/PistolSlot.color = normal_color
		$ShopColor/Container/KnifeSlot.color = normal_color
		$ShopColor/Container/PlayerSlot.color = normal_color
		show_panel(shotgun_panel)
	clear_perk_info()

func _on_pistol_button_pressed() -> void:
	$ShopColor/Container/ShotgunSlot.color = normal_color
	$ShopColor/Container/M16Slot.color = normal_color
	$ShopColor/Container/PistolSlot.color = select_color
	$ShopColor/Container/KnifeSlot.color = normal_color
	$ShopColor/Container/PlayerSlot.color = normal_color
	show_panel(pistol_panel)
	clear_perk_info()
	
func _on_knife_button_pressed() -> void:
	$ShopColor/Container/ShotgunSlot.color = normal_color
	$ShopColor/Container/M16Slot.color = normal_color
	$ShopColor/Container/PistolSlot.color = normal_color
	$ShopColor/Container/KnifeSlot.color = select_color
	$ShopColor/Container/PlayerSlot.color = normal_color
	show_panel(knife_panel)
	clear_perk_info()
func _on_player_button_pressed() -> void:
	$ShopColor/Container/ShotgunSlot.color = normal_color
	$ShopColor/Container/M16Slot.color = normal_color
	$ShopColor/Container/PistolSlot.color = normal_color
	$ShopColor/Container/KnifeSlot.color = normal_color
	$ShopColor/Container/PlayerSlot.color = select_color
	show_panel(player_panel)	
	clear_perk_info()
	
func show_panel(panel: Control):
	# Скрыть все
	player_panel.hide()
	knife_panel.hide()
	pistol_panel.hide()
	m16_panel.hide()
	shotgun_panel.hide()
	# Показать выбранную
	panel.show()

func buy_perk(perk: Perk, button: Button, label: Label, color_rect: ColorRect):
	if player.perk_manager.buy_perk(perk):
		button.disabled = true
		label.text = tr("PERK_BOUGHT")
		color_rect.color = Color(0, 0.35, 0.00, 1.0)
		update_points_shop_display(player.points)
		buying_sound.play()

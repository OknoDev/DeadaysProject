class_name Pickup extends Area3D

enum PICKUP_TYPES{HEALTH, WEAPON, AMMO}
enum WEAPONS {RIFLE, SHOTGUN, PISTOL}
@export var pickup_type = PICKUP_TYPES.HEALTH
@export var weapon_type = WEAPONS.RIFLE
@export var pickup_amnt = 20

signal picked_up

func pickup():
	queue_free()
	picked_up.emit()
	

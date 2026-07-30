class_name Pickup extends Area3D

enum PICKUP_TYPES{HEALTH, WEAPON, AMMO}
enum WEAPONS {RIFLE, SHOTGUN, PISTOL}
@export var pickup_type = PICKUP_TYPES.HEALTH
@export var weapon_type = WEAPONS.RIFLE
@export var pickup_amnt = 20
@export var interactive: bool = false
signal picked_up

func pickup():
	queue_free()
	picked_up.emit()
	
func interact(player: Node3D):
	if not interactive:
		return
	if player && player.health_manager.cur_health < player.health_manager.max_health:
		player.health_manager.heal(pickup_amnt)
		if player.pickup_medkit:
			player.pickup_medkit.play()
	pickup()

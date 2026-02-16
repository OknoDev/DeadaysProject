extends Area3D
@onready var health_manager: Node3D = %HealthManager
@onready var weapon_manager: Node3D = %WeaponManager

func _ready():
	area_entered.connect(on_area_entered)
	
func on_area_entered(pickup: Area3D):
	var delete_on_pickup = true
	if pickup is Pickup:
		match pickup.pickup_type:
			Pickup.PICKUP_TYPES.HEALTH:
				if health_manager.cur_health < health_manager.max_health:
					health_manager.heal(pickup.pickup_amnt)
					$PickupMedkit.play()
				else:
					delete_on_pickup = false
			Pickup.PICKUP_TYPES.AMMO:
				var weapon : Weapon = weapon_manager.get_weapon_from_pickup_type(pickup.weapon_type)
				if weapon.ammo < weapon.max_ammo && weapon_manager.weapons_unlocked[weapon.get_index()]:
					weapon.add_ammo(pickup.pickup_amnt)
					$PickupAmmo.play()
				else:
					delete_on_pickup = false
	if delete_on_pickup:
		pickup.pickup()

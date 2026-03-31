class_name HitBox extends Area3D

@export var weak_spot = false
@export var critical_damage_multiplier = 2.0
signal on_hurt(damage_data: DamageData)
var monster: Node

func _ready() -> void:
	var parent = get_parent()
	while parent and not parent.is_in_group("zombies"):
		parent = parent.get_parent()
	monster = parent
		
func hurt(damage_data: DamageData):

	if damage_data.anatomy_active and weak_spot and monster:
		damage_data.amount = monster.zombie_health_manager.cur_health
		on_hurt.emit(damage_data)
		return
	if weak_spot:
		damage_data.amount *= critical_damage_multiplier
	on_hurt.emit(damage_data)

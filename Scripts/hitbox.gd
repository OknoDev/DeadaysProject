class_name HitBox extends Area3D

@export var weak_spot = false
@export var critical_damage_multiplier = 2.0
signal on_hurt(damage_data: DamageData)

func hurt(damage_data: DamageData):
	if weak_spot:
		damage_data.amount *= critical_damage_multiplier
	on_hurt.emit(damage_data)

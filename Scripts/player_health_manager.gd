extends Node3D
# ЭТО ТОЛЬКО ДЛЯ ИГРОКА!

@export var max_health = 100
@onready var cur_health = max_health

signal died
signal damaged
signal health_change(cur_health, max_health)

func _ready():
	health_change.emit(cur_health, max_health)

func hurt(damage_data: DamageData):
	if cur_health <= 0:
		return
	
	cur_health -= damage_data.amount

	if cur_health <= 0:
		died.emit()
	else:
		damaged.emit()
	
	health_change.emit(cur_health, max_health)

func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health = clamp(cur_health + amount, 0, max_health)
	health_change.emit(cur_health, max_health)

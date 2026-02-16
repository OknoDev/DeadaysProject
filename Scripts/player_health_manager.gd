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
	print("PlayerHealthManager: получен урон ", damage_data.amount, ", здоровье: ", cur_health)
	
	if cur_health <= 0:
		print("PlayerHealthManager: ИГРОК УМЕР!")
		died.emit()
	else:
		damaged.emit()
	
	health_change.emit(cur_health, max_health)

func heal(amount: int):
	if cur_health <= 0:
		return
	cur_health = clamp(cur_health + amount, 0, max_health)
	health_change.emit(cur_health, max_health)

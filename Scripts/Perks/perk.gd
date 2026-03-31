extends Resource
class_name Perk

@export var price: int
@export var perk_type: int #0 - персонаж, 1 - нож, 2 - пистолет, 3 - M16 и 4 - дробовик
@export var modifiers: Dictionary = {}
@export var name_key: String = ""
@export var desc_key: String = ""
@export var icon: Texture2D

func apply(player: Node, weapon: Node = null) -> void:
	pass

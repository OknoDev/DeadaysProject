extends ColorRect
@export var perk: Perk
@onready var shop = %ShopMenu

func _ready():
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered():
	shop.update_perk_info(perk)

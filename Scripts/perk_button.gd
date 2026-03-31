extends Button

@export var perk: Perk
@onready var shop: Control = %ShopMenu
@onready var perk_price: Label = $"../PerkPrice"
@onready var color_rect: ColorRect = $".."

func _ready():
	pressed.connect(_on_pressed)

func _on_pressed():
	if shop and shop.has_method("buy_perk"):
		shop.buy_perk(perk, self, perk_price, color_rect)

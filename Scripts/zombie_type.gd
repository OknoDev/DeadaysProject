# zombie_type.gd
class_name ZombieType extends Resource

@export_category("Basic Settings")
@export var scene: PackedScene  # Сцена зомби
@export var display_name: String = "Zombie"  # Имя для отображения

@export_category("Spawning Rules")
@export var min_wave: int = 1  # С какой волны появляется
@export var max_wave: int = 999  # До какой волны появляется
@export var spawn_weight: float = 1.0  # Вероятность появления
@export var max_per_wave: int = -1  # Максимум за волну (-1 = без ограничений)

@export_category("Stats")
@export var health: int = 100
@export var damage: int = 10
@export var speed: float = 2.0
@export var is_boss: bool = false  # Является ли боссом

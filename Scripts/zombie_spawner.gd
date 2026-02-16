extends Node3D

@export var WaveManager: Node3D

@export var normal_zombie_scene: PackedScene
@export var fast_zombie_scene: PackedScene
@export var heavy_zombie_scene: PackedScene

@export var skull_zombie_scene: PackedScene
@export var ice_skull_zombie_scene: PackedScene

var spawn_probabilities: Dictionary = {
	"normal": 100.0,
	"fast": 0.0,
	"heavy": 0.0,
	"skull": 0.0,
	"ice_skull": 0.0
}


var is_active = false



func _ready():
	WaveManager.register_spawner(self)
	is_active = true
func set_spawn_probabilities(probabilities: Dictionary):
	spawn_probabilities = probabilities.duplicate()
	print(name, ": вероятности - нормальные:", spawn_probabilities.get("normal", 0), 
		  " быстрые:", spawn_probabilities.get("fast", 0),
		  " тяжелые:", spawn_probabilities.get("heavy", 0),
		  " черепа:", spawn_probabilities.get("skull", 0),
		  " лед.черепа:", spawn_probabilities.get("ice_skull", 0))

func choose_random_zombie_type() -> String:
	var total_weight = 0.0
	for weight in spawn_probabilities.values():
		total_weight += weight
	
	if total_weight <= 0:
		return "normal"
	
	var random_value = randf() * total_weight
	var current_weight = 0.0
	
	for zombie_type in ["normal", "fast", "heavy", "skull", "ice_skull"]:
		current_weight += spawn_probabilities.get(zombie_type, 0.0)
		if random_value <= current_weight:
			return zombie_type
	
	return "normal"
	

func spawn_random_zombie():
	if WaveManager.zombies_alive >= WaveManager.max_zombies_on_scene:
		return false
	
	var zombie_type = choose_random_zombie_type()
	var zombie_scene = get_zombie_scene(zombie_type)
	
	if not zombie_scene:
		print("ОШИБКА: нет сцены для типа ", zombie_type)
		return false
	
	var new_zombie = zombie_scene.instantiate()
	get_parent().add_child(new_zombie)
	new_zombie.global_position = global_position
	new_zombie.add_to_group("zombies")
	
	if new_zombie.has_signal("died"):
		new_zombie.died.connect(_on_zombie_died.bind(zombie_type))
	
	WaveManager.report_zombie_spawned()
	
	print(name, ": заспавнен ", zombie_type, " (", spawn_probabilities.get(zombie_type, 0), "%)")
	return true


func get_zombie_scene(zombie_type: String) -> PackedScene:
	match zombie_type:
		"fast":
			return fast_zombie_scene
		"heavy":
			return heavy_zombie_scene
		"skull":
			return skull_zombie_scene
		"ice_skull":
			return ice_skull_zombie_scene
		_:  # normal или любой другой
			return normal_zombie_scene
	
	
func _on_zombie_died(zombie_type: String):
	WaveManager.zombie_died(zombie_type)


func can_spawn_more() -> bool:
	return true

extends Node3D
@onready var smoke: GPUParticles3D = $Smoke
static var active_gib_sounds = 0
const MAX_GIB_SOUNDS = 3

func _ready() -> void:
	smoke.emitting = true
	if active_gib_sounds < MAX_GIB_SOUNDS:
		active_gib_sounds += 1
		
		$GibSound.pitch_scale = randf_range(0.8, 1.1)
		$GibSound.finished.connect(_on_gib_sound_finished)
		$GibSound.play()

func _on_gib_sound_finished():
	active_gib_sounds -= 1
	$GibSound.finished.disconnect(_on_gib_sound_finished)

func _on_smoke_finished() -> void:
	queue_free()
	

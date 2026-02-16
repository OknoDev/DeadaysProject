extends Node3D
@onready var smoke: GPUParticles3D = $Smoke

func _ready() -> void:
	smoke.emitting = true
	$GibSound.pitch_scale = randf_range(0.8, 1.1)
	$GibSound.play()

func _on_smoke_finished() -> void:
	queue_free()
	

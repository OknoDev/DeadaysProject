class_name ProceduralRecoil
extends Node3D

# Rotations
var currentRotation : Vector3
var targetRotation : Vector3

@export_category("Recoil Vectors")
## 3D vector representing the recoil force applied on each axis.
@export var recoil : Vector3
## 3D vector representing the recoil force applied on each axis while aiming.
@export var aimRecoil : Vector3

@export_category("Settings")
## Rate at which the current rotation lerps to the target rotation
@export var snappiness : float
## Speed at which the weapon returns to its original position.
@export var returnSpeed : float

@export var overshoot_factor: float = 1.2
## Node containing "fired" signal and weapon logic
@export var action_node: Node3D

@export var player_node: Node3D

func _ready():
	if action_node and action_node.has_signal("fired") and not action_node.is_connected("fired", recoilFire):
		action_node.connect("fired", recoilFire)
		print_debug("fired")


func recoilFire(isAiming : bool = false):
	var applied_recoil: Vector3
	if isAiming:
		applied_recoil = Vector3(aimRecoil.x, randf_range(-aimRecoil.y, aimRecoil.y), randf_range(-aimRecoil.z, aimRecoil.z))
	else:
		applied_recoil = Vector3(recoil.x, randf_range(-recoil.y, recoil.y), randf_range(-recoil.z, recoil.z))
	
	if player_node and player_node.has_method("add_recoil"):
		player_node.add_recoil(applied_recoil)


func setRecoil(newRecoil : Vector3):

	recoil = newRecoil


func setAimRecoil(newRecoil : Vector3):
	"""
	Change recoil value for aiming.
	"""
	aimRecoil = newRecoil

extends Node3D

var anim_player: AnimationPlayer = null
func _ready():
	for child in get_children():
		child.visible = false
	var indx = randi_range(0, get_child_count() - 1)
	var selected = get_child(indx)
	selected.visible = true
	anim_player = selected.find_child("AnimationPlayer", true, false)
	
func damage_anim():
	anim_player.play("damaged")

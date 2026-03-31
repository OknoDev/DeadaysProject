extends Node3D

class_name BulletEmitter

var bodies_to_exclude = []
var damage = 1
var emitter_owner: Node = null
var weapon_type: int = 0
var anatomy_active: bool = false

func set_damage(d: int):
	damage = d
	for child in get_children():
		if child is BulletEmitter:
			child.set_damage(d)
			
func set_bodies_to_exclude(bodies: Array):
	bodies_to_exclude = bodies
	for child in get_children():
		if child is BulletEmitter:
			child.set_bodies_to_exclude(bodies)
			
func set_emitter_owner(node: Node):
	emitter_owner = node
	for child in get_children():
		if child is BulletEmitter:
			child.set_owner(node)

			
func fire():
	for child in get_children():
		if child is BulletEmitter:
			child.anatomy_active = anatomy_active
			child.weapon_type = weapon_type
			child.fire()
	
			 

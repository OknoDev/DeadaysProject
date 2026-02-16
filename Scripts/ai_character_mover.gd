extends CharacterMover

@export var turn_speed = 300.0
var facing_dir : Vector3
@onready var navigation_agent_3d: NavigationAgent3D = $NavigationAgent3D
var moving = false

var current_vertical_velocity: float = 0.0
@export var vertical_speed: float = 2.0
@export var target_height: float = 3.0 

func _ready():
	super()
	if is_flying:
		super.set_gravity(0.0)
		target_height = global_position.y
	
	
	facing_dir = -character_body.global_transform.basis.z

func set_facing_dir(new_face_dir: Vector3):
	facing_dir = new_face_dir
	if not is_flying:
		facing_dir.y = 0.0
		facing_dir = facing_dir.normalized()

func move_to_point(point: Vector3):
	moving = true
	
	if is_flying:
		var horizontal_point = Vector3(point.x, global_position.y, point.z)
		navigation_agent_3d.target_position = horizontal_point
	else:
		navigation_agent_3d.target_position = point
	
func stop_moving():
	moving = false
	set_move_dir(Vector3.ZERO)
	
func _physics_process(delta):
	if moving:
		if is_flying:
			var next_path_point = navigation_agent_3d.get_next_path_position()
			next_path_point.y = global_position.y
			
			var dir_to_next_point = next_path_point - global_position
			set_move_dir(dir_to_next_point)
			
			update_vertical_movement(delta)
		else:
			set_move_dir(navigation_agent_3d.get_next_path_position() - global_position)
	
	super(delta)
	var fwd = -character_body.global_transform.basis.z
	var right = character_body.global_transform.basis.x
	
	var horizontal_facing_dir = facing_dir
	horizontal_facing_dir.y = 0
	horizontal_facing_dir = horizontal_facing_dir.normalized()
	
	var angle_diff = fwd.angle_to(facing_dir)
	var turn_dir = 1
	if right.dot(facing_dir) > 0:
		turn_dir  = -1
		
	var turn_amnt = delta * deg_to_rad(turn_speed)
	if turn_amnt > angle_diff:
		turn_amnt = angle_diff
		
	character_body.global_rotation.y += turn_amnt * turn_dir

func update_vertical_movement(delta):
	if not is_flying:
		return
	if player:
		var player_height = player.global_position.y
		target_height = player_height + 2.0
		
	var height_difference = target_height - character_body.global_position.y
	
	var vertical_acceleration = height_difference * 2.0
	current_vertical_velocity = lerp(current_vertical_velocity, vertical_acceleration, delta * 5.0)
	
	current_vertical_velocity = clamp(current_vertical_velocity, -vertical_speed, vertical_speed)
	
	character_body.velocity.y = current_vertical_velocity
	
	var hover_oscillation = sin(Time.get_ticks_msec() * 0.002) * 0.05
	character_body.velocity.y += hover_oscillation

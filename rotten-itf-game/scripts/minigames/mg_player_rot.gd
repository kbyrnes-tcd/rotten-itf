extends Node2D

# INIT: FSM, Global vars for active ray/dir
enum State { IDLE, GROWING, STOPPED }
var current_state : State = State.IDLE
var active_ray : RayCast2D
var active_dir : Vector2
var tip_point : Vector2

@export var rays: Array[RayCast2D] = []
var pts : PackedVector2Array = PackedVector2Array([])

func _ready() -> void:
	pts = $vine.points
	tip_point = pts[pts.size()-1]

func get_snapped_direction():
	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - pts[pts.size()-1]
	var angle = diff.angle()
	var snapped_angle = snappedf(angle, PI/2.0)
	var dir_vector = Vector2(cos(snapped_angle), sin(snapped_angle)).round()
	var dir_ray : RayCast2D
	match dir_vector:
		Vector2(1,0):
			dir_ray = $right
		Vector2(-1,0):
			dir_ray = $left
		Vector2(0,1):
			dir_ray = $down
		Vector2(0, -1):
			dir_ray = $up
		_:
			dir_ray = $right
	return [dir_vector, dir_ray]

func update_rays(new_pos : Vector2):
	var new_pos_global = $vine.to_global(new_pos)
	for ray in rays:
		ray.update_pos(new_pos_global)

var breathe_room = Vector2(40,20)

func process_idle():
	#print("IDLE")
	# IDLE: waiting for click/direction
	var dir_data = get_snapped_direction()
	active_dir = dir_data[0]
	active_ray = dir_data[1]
	if active_ray == null:
		return # no valid direction

	# VISUAL UPDATE: shows until col_point
	if active_ray.is_colliding():
		var preview_point_global = active_ray.get_collision_point() - (breathe_room * active_dir)
		pts[pts.size() - 1] = $vine.to_local(preview_point_global)
		$vine.points = pts

func fork_check() -> bool:
	# check other rays for possible dir-changes
	# IGNORE current ray and opp_dir
	var check : bool = false
	for ray in rays:
		if ray == active_ray or ray.name == active_ray.get_opp_dir_name():
			continue
		check = check or ray.can_i_extend()
	return check

func process_growing(delta: float):
	print("GROWING")
	# GROWING: actively extending toward active_ray's direction, checking other 3 rays each frame from the current tip for extending,
	# and checking active_ray itself for collision (mazobstacle)
	
	# reposition all rays to the curr tip_point per frame for live tip-ray detection
	update_rays(tip_point)
	var rot_speed = 300.0
	
	if !active_ray.is_colliding():
		# nothing to grow towards
		current_state = State.STOPPED
		return
	
	elif active_ray.is_colliding():
		var col_point : Vector2 = $vine.to_local(active_ray.get_collision_point())
		# need to convert this to vine's local space so that it can be compared to tip_point eventually
		col_point += breathe_room * active_dir

		# check OTHER 3 rays for can_i_extend() 
		# -> if true, stop extension here... found fork point
		if fork_check():
			print("FORK FOUND!")
			current_state = State.STOPPED
			return

		tip_point = tip_point + active_dir * rot_speed * delta
		pts[pts.size()-1] = tip_point
		$vine.points = pts

		# Then, trans. to State.STOPPED and append the final point in there
		if tip_point.is_equal_approx(col_point):
			current_state = State.STOPPED
			return

func process_stopped():
	print("STOPPING")
	# STOPPED: either hit col_point or a perpendicular ray signaled as i_can_extend
	pts.append(tip_point) 
	$vine.points = pts
	update_rays(tip_point)
	current_state = State.IDLE

func _physics_process(delta: float) -> void:
	#print(current_state)
	match current_state:
		State.IDLE:
			process_idle()
		State.GROWING:
			process_growing(delta)
		State.STOPPED:
			process_stopped()
			
	if Input.is_action_just_pressed("click") && current_state == State.IDLE:
		current_state = State.GROWING

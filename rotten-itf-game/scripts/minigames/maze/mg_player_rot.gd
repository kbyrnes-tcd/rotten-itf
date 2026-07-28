extends Node2D

# INIT: FSM, Global vars for active ray/dir
enum State { IDLE, GROWING, STOPPED }
@export var graph: MazeData
var current_state : State = State.IDLE
var active_node : String
var active_dir : String
var tip_point : Vector2
var preview_tip_point : Vector2  # for idle debugging

var pts : PackedVector2Array = PackedVector2Array([])

func _ready() -> void:
	pts = $vine.points
	tip_point = pts[pts.size()-1]
	var start_pos = graph.graph_data["A"]["pos"]
	print(start_pos)

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
	return [dir_vector, dir_ray]

var breathe_room = Vector2(0,0)

func process_idle():
	# IDLE: waiting for click/direction - MOUSE CONTROL
	#var dir_data = get_snapped_direction()
	#active_dir = dir_data[0]
	#active_ray = dir_data[1]

	# WASD/ARROW KEYS CONTROL
	if Input.is_action_just_pressed("up"):
		active_dir = "up"
	if Input.is_action_just_pressed("down"):
		active_dir = "down"
	if Input.is_action_just_pressed("left"):
		active_dir = "left"
	if Input.is_action_just_pressed("right"):
		active_dir = "right"
	
	if active_dir == null:
		return # no valid dir detected
	
	# VISUAL UPDATE: shows active dir until node along that edge_dir
	#if active_ray.is_colliding():
		#var preview_point_global = active_ray.get_collision_point()
		#preview_tip_point = $debug_preview.to_local(preview_point_global)
		#$debug_preview.points[-1] = preview_tip_point
#
#func fork_check() -> bool:
	## check other rays for possible dir-changes
	#var check : bool = false
	#for ray in rays:
		#ray.force_raycast_update()
		## IGNORE current ray and opp_dir
		#if ray == active_ray or ray.name == active_ray.get_opp_dir_name():
			#continue
		#check = check or ray.can_i_extend()
	#return check
#
#func process_growing(delta: float):
	#print("GROWING")
	## GROWING: actively extending toward active_ray's direction, checking other 3 rays each frame from the current tip for extending,
	## and checking active_ray itself for collision (mazobstacle)
	#
	## reposition all rays to the curr tip_point per frame for live tip-ray detection
	#update_rays(tip_point)
	#var rot_speed = 300.0
	##active_ray.active()
	#
	#if !active_ray.is_colliding():
		## nothing to grow towards
		#current_state = State.STOPPED
		#return
	#
	#elif active_ray.is_colliding():
		##("collision detected ahead, visual growth update incoming")
		#var col_point : Vector2 = $vine.to_local(active_ray.get_collision_point())
		## need to convert this to vine's local space so that it can be compared to tip_point eventually
		#col_point += breathe_room * active_dir
#
		## VISUAL UPDATE: move tip along
		#tip_point = tip_point + active_dir * rot_speed * delta
		#pts[pts.size()-1] = tip_point
		#$vine.points = pts
		#
		## check OTHER 3 rays for can_i_extend() 
		## -> if true, stop extension here... found fork point
		#if fork_check():
			#print("FORK FOUND!")
			#current_state = State.STOPPED
			#return
#
		## Then, trans. to State.STOPPED and append the final point in there
		#if tip_point.is_equal_approx(col_point):
			#current_state = State.STOPPED
			#return
#
#func process_stopped():
	#print("STOPPING")
	## add tip_point to points, moving rot along concretely & update its rays from that pos.
	#pts.append(tip_point)
	#$vine.points = pts
	#update_rays(tip_point)
#
	## resync the debug preview to the appended point
	#var tip_global = $vine.to_global(tip_point)
	#var tip_local_preview = $debug_preview.to_local(tip_global)
	#$debug_preview.points = PackedVector2Array([tip_local_preview, tip_local_preview])
#
	#active_dir = Vector2(0,0)
	#active_ray = null
	#current_state = State.IDLE

func _physics_process(delta: float) -> void:
	#print(current_state)
	match current_state:
		State.IDLE:
			process_idle()
		#State.GROWING:
			#process_growing(delta)
		#State.STOPPED:
			#process_stopped()
			
	if Input.is_action_just_pressed("click") && current_state == State.IDLE:
		current_state = State.GROWING

extends Node2D

# INIT: FSM, Global vars for active ray/dir
enum State { IDLE, GROWING, STOPPED, WON }
@export var graph: MazeData
var current_state : State = State.IDLE
var active_node : String
var next_node : String
var active_dir : String
var tip_point : Vector2
var pts : PackedVector2Array = PackedVector2Array([])
var debug_vine : PackedVector2Array = PackedVector2Array([])  # for idle debugging
var debug_tip_point : Vector2

func _ready() -> void:
	pts = $vine.points
	tip_point = pts[pts.size()-1]
	debug_vine = $vine_debug.points
	debug_tip_point = debug_vine[-1]
	active_node = "A"

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
	# IDLE: waiting for input to set direction
	
	# MOUSE CONTROL
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
	if graph.get_valid_dirs(active_node).has(active_dir):
		var n_node = graph.get_next_node(active_node, active_dir)
		debug_tip_point = graph.get_pos(n_node)
		debug_vine[-1] = $vine_debug.to_local(debug_tip_point)
		$vine_debug.points = debug_vine

func clear_preview():
	# clear debug view
	debug_vine = PackedVector2Array([[0,0], [0,0]])
	$vine_debug.points = debug_vine
	# hide arrow_dirs
	for dir_sprite in $dir_arrows.get_children():
		dir_sprite.visible = false
		
func update_preview():
	# update debug view to new tip
	debug_tip_point = graph.get_pos(next_node)
	debug_vine = [$vine_debug.to_local(debug_tip_point), $vine_debug.to_local(debug_tip_point)]
	$vine_debug.points = debug_vine
	
	# show & update arrow_dirs pos
	$dir_arrows.position = $dir_arrows.get_parent().to_local(debug_tip_point)
	for dir_sprite in $dir_arrows.get_children():
		dir_sprite.visible = true

func process_growing(delta: float):
	#print("GROWING")
	var grow_speed: float = 200.0  # pixels /sec

	# if active_node can grow towards active_dir, do... extend the tip
	if graph.get_valid_dirs(active_node).has(active_dir):
		# clear debug preview & arrow_dirs
		clear_preview()
		next_node = graph.get_next_node(active_node, active_dir)
		var n_node_pos = graph.get_pos(next_node)
		tip_point = graph.get_pos(next_node)

		# extend tip incr.
		var current_tip = to_global(pts[-1])
		var moving_tip = current_tip.move_toward(tip_point, grow_speed * delta)
		pts[-1] = $vine.to_local(moving_tip)
		$vine.points = pts

		# trans. to stopped when close enough
		if moving_tip.is_equal_approx(n_node_pos):
			current_state = State.STOPPED

	else: current_state = State.IDLE

func process_stopped():	
	# actually append point to arr
	pts.append($vine.to_local(tip_point))
	$vine.points = pts
	
	# update preview first then pointers ?!??!?!? ORDER IS ANNOYING.
	active_node = next_node
	if active_node == "Z":
		print("YOU WON")
		current_state = State.WON
		return
		
	active_dir = ""
	update_preview()
	
	current_state = State.IDLE
	return

func _physics_process(delta: float) -> void:
	match current_state:
		State.IDLE:
			process_idle()
		State.GROWING:
			process_growing(delta)
		State.STOPPED:
			process_stopped()
		State.WON:
			clear_preview()
			pass
			
	if Input.is_action_just_pressed("click") && current_state == State.IDLE:
		current_state = State.GROWING

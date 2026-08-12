extends Node2D

# INIT: FSM, Global vars for active ray/dir
enum State { IDLE, GROWING, STOPPED, WON }
@export var graph: MazeData
var current_state : State = State.IDLE
var active_node : String
var next_node : String
var active_dir
var tip_point : Vector2
var pts : PackedVector2Array = PackedVector2Array([])
var debug_vine : PackedVector2Array = PackedVector2Array([])  # for idle debugging
var debug_tip_point : Vector2
signal active_node_changed

@export var debug : bool

func _ready() -> void:
	pts = $vine.points
	tip_point = pts[pts.size()-1]
	debug_vine = $vine_debug.points
	debug_tip_point = debug_vine[-1]
	active_node = "A"
	active_node_changed.emit(active_node)

func get_snapped_direction():
	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - tip_point
	var angle = diff.angle()
	var snapped_angle = snappedf(angle, PI/2.0)
	var dir_vector = Vector2(cos(snapped_angle), sin(snapped_angle)).round()
	var dir
	match dir_vector:
		Vector2(1,0):
			dir = "right"
		Vector2(-1,0):
			dir = "left"
		Vector2(0,1):
			dir = "down"
		Vector2(0, -1):
			dir = "up"
		_:
			dir = null
	return dir

func process_idle():
	# IDLE: waiting for input to set direction
	
	# MOUSE CONTROL
	#active_dir = get_snapped_direction()

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
	if active_dir and !graph.get_valid_dirs(active_node).has(active_dir):
		active_dir = null
		return
	
	# VISUAL UPDATE: shows active dir until node along that edge_dir
	#if graph.get_valid_dirs(active_node).has(active_dir):
		#var n_node = graph.get_next_node(active_node, active_dir)
		#debug_tip_point = graph.to_global(graph.get_pos((n_node)))
		#debug_vine[-1] = $vine_debug.to_local(debug_tip_point)
		#$vine_debug.points = debug_vine

func clear_preview():
	# clear debug view
	debug_vine = PackedVector2Array([[0,0], [0,0]])
	$vine_debug.points = debug_vine
	# hide arrow_dirs
	$dir_arrows.visible = false
		
func update_preview():
	# update debug view to new tip
	debug_tip_point = graph.to_global(graph.get_pos((next_node)))
	debug_vine = [$vine_debug.to_local(debug_tip_point), $vine_debug.to_local(debug_tip_point)]
	$vine_debug.points = debug_vine
	
	# show & update arrow_dirs pos
	$dir_arrows.visible = true
	$dir_arrows.position = $dir_arrows.get_parent().to_local(debug_tip_point)

func process_growing(delta: float):
	AudioManager.play_fx("grow")
	#print("GROWING")
	var grow_speed: float = 90.0  # pixels /sec

	# if active_node can grow towards active_dir, do... extend the tip
	if graph.get_valid_dirs(active_node).has(active_dir):
		# clear debug preview & arrow_dirs
		clear_preview()
		next_node = graph.get_next_node(active_node, active_dir)
		var n_node_pos = graph.to_global(graph.get_pos((next_node)))
		tip_point = graph.to_global(graph.get_pos((next_node)))

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
	AudioManager.stop_fx()
	# actually append point to arr
	pts.append($vine.to_local(tip_point))
	$vine.points = pts
	#print('appended point calling update...')
	#RotVisual.update_texture_indices($vine.points)
	
	var incoming_dir = active_dir
	active_node = next_node
	active_node_changed.emit(next_node)
	
	# connector nodes
	if graph.is_node_conn(active_node):
		var opposite_dir = {"left":"right","right":"left","up":"down","down":"up"}[incoming_dir]
		var valid_dirs = graph.get_valid_dirs(active_node)
		valid_dirs.erase(opposite_dir) # don't just bounce back in the active opp. dir...
		active_dir = valid_dirs[0]
		update_preview()
		current_state = State.GROWING
		return
	
	# win state
	if active_node.contains("Z"):
		print("YOU WON!!!!!!!!!!!!!!!!!!!!!!!!!")
		current_state = State.WON
		clear_preview()
		if !debug:
			GameGlobals.unload_minigame()
		return
		
	active_dir = null
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
		#State.WON:
			#clear_preview()
			#pass
			
	if current_state == State.IDLE and active_dir:
		current_state = State.GROWING

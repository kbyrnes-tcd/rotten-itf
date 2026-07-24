extends Node2D

@export var rays: Array[RayCast2D] = []
var pts : PackedVector2Array = PackedVector2Array([])
var up_extend : bool
var down_extend : bool
var left_extend : bool
var right_extend : bool
# this script is in charge of the overall game and line2d, it should check which dir the user's mousepos is registering
# and emit the right signals/call the right methods on that directional raycast2d

func _ready() -> void:
	pts = $vine.points

#get direction from player - up,down,left,right
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
	# returns angle dir vector, and associated ray

func update_rays(new_pos : Vector2):
	#update all dir rays to have new pos
	for ray in rays:
		ray.update_pos(new_pos)


var breathe_room = Vector2(50,50)
func _physics_process(_delta: float) -> void:
	var dir_data = get_snapped_direction()
	var dir = dir_data[0]
	var active_ray : RayCast2D = dir_data[1]

	if active_ray == null:
		return # no valid direction

	if active_ray.can_i_extend():
		# VISUAL
		# i can extend?! then extend until collision point
		var preview_point_global = active_ray.get_collision_point() - (breathe_room * dir)
		pts[pts.size() - 1] = $vine.to_local(preview_point_global)
		$vine.points = pts
		if Input.is_action_pressed("click"):
			# ACTUALLY EXTENDING
			var col_point = active_ray.get_collision_point()
			col_point -= breathe_room * dir 
			pts.append($vine.to_local(col_point))
			$vine.points = pts
			update_rays(col_point)
	else:
		pts[pts.size() - 1] = pts[pts.size() - 2] # idk if this will work later...
		$vine.points = pts

func _on_up_can_extend(extend:bool) -> bool:
	up_extend = extend
	return extend

func _on_down_can_extend(extend:bool) -> bool:
	down_extend = extend
	return extend

func _on_left_can_extend(extend:bool) -> bool:
	left_extend = extend
	return extend

func _on_right_can_extend(extend:bool) -> bool:
	right_extend = extend
	return extend

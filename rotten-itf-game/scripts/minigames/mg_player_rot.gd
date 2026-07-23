extends Node2D
var pts : PackedVector2Array = PackedVector2Array([])
@export var ray_manager : Script = preload("res://scripts/minigames/mg_dir_rays.gd")
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
	var diff = mouse_pos - global_position
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

func _physics_process(_delta: float) -> void:
	var dir_data = get_snapped_direction()
	var dir = dir_data[0]
	var active_ray = dir_data[1]

	if active_ray == null:
		return # no valid direction

	if Input.is_action_pressed("click"):
		if active_ray.can_i_extend():
			print("growing out in dir " + active_ray.name)
			# line-extendinglogic tbd...
		else:
			print("CAN'T for " + active_ray.name)

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

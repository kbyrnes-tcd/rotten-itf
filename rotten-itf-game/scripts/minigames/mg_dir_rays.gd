extends RayCast2D

var min_dist : int = 200
var col_point : Vector2
var ray_origin : Vector2
var direction_vector : Vector2
var opp_dir_name : String

# this script will be in charge of each individual ray: up, down, left, right
# it should check if it can extend, and extend if the player is clicking (has received signal from manager)

func _ready() -> void:
	match name:
		"right":
			direction_vector = Vector2(1,0)
			opp_dir_name = "left"
		"left":
			direction_vector = Vector2(-1,0)
			opp_dir_name = "right"
		"down":
			direction_vector = Vector2(0,1)
			opp_dir_name = "up"
		"up":
			direction_vector = Vector2(0, -1)
			opp_dir_name = "down"
	ray_origin = global_position

func get_opp_dir_name() -> String:
	return opp_dir_name

func can_i_extend():
	var extend : bool = false
	# calc. nearest col.point from this ray and if it matches min_dist
	if is_colliding() and ray_origin.distance_to(col_point) > min_dist:
		extend = true
	# if it doesnt have a col (that matches min_dist) then it cannot extend
	else:
		extend = false
	return extend
	
func _physics_process(_delta: float) -> void:
	var preview_length = 600.0
	# computing in GLOBAL
	# just the ray origin and its target based on max_length and direction
	var target_global : Vector2 = ray_origin + direction_vector * preview_length
	target_position = to_local(target_global)
	
	force_raycast_update()
	if is_colliding():
		col_point = get_collision_point()

func update_pos(new_pos : Vector2):
	# update pos st. global_pos = target_pos 
	# also incr. target_pos if necessary
	ray_origin = new_pos
	global_position = new_pos
	pass 

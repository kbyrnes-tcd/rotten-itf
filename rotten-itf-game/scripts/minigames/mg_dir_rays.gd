extends RayCast2D

var min_dist : int = 200
var col_point : Vector2
var ray_origin : Vector2
var direction_vector : Vector2
var opp_dir_name : String
var arrow_sprite: Sprite2D
var self_active: bool = false
var preview_length = 600.0 # make sure to keep same as other scr.

# this script will be in charge of each individual ray: up, down, left, right

func _ready() -> void:
	match name:
		"right":
			direction_vector = Vector2(1,0)
			opp_dir_name = "left"
			arrow_sprite = get_node("%s_sprite" %name)
		"left":
			direction_vector = Vector2(-1,0)
			opp_dir_name = "right"
			arrow_sprite = get_node("%s_sprite" %name)
		"down":
			direction_vector = Vector2(0,1)
			opp_dir_name = "up"
			arrow_sprite = get_node("%s_sprite" %name)
		"up":
			direction_vector = Vector2(0, -1)
			opp_dir_name = "down"
			arrow_sprite = get_node("%s_sprite" %name)
	ray_origin = global_position

func get_opp_dir_name() -> String:
	return opp_dir_name

func active():
	self_active = true

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
	# computing in GLOBAL
	# just the ray origin and its target based on max_length and direction
	var target_global : Vector2 = ray_origin + direction_vector * preview_length
	target_position = to_local(target_global)
	
	force_raycast_update()
	if is_colliding():
		col_point = get_collision_point()
		
	# render move-able dir arrow/sprite
	if can_i_extend():
		arrow_sprite.visible = true
	else: 
		arrow_sprite.visible = false

func update_pos(new_pos: Vector2) -> void:
	ray_origin = new_pos
	global_position = new_pos
	var target_global : Vector2 = ray_origin + direction_vector * preview_length
	target_position = to_local(target_global)
	force_raycast_update()
	if is_colliding():
		col_point = get_collision_point()
	arrow_sprite.visible = can_i_extend()

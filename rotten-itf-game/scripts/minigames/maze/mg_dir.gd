#extends RayCast2D
#
#var min_dist : int = 350
#var col_point : Vector2
#var ray_origin : Vector2
#var direction_vector : Vector2
#var opp_dir_name : String
#var arrow_sprite: Sprite2D
#var self_active: bool = false
#var preview_length = 600.0 # make sure to keep same as other scr.
#
## this script will be in charge of each individual ray: up, down, left, right
#func _ready() -> void:
	#match name:
		#"right":
			#arrow_sprite = get_node("%s_sprite" %name)
		#"left":
			#arrow_sprite = get_node("%s_sprite" %name)
		#"down":
			#arrow_sprite = get_node("%s_sprite" %name)
		#"up":
			#arrow_sprite = get_node("%s_sprite" %name)
#
#func can_i_extend():
	#var extend : bool = false
	## calc. nearest col.point from this ray and if it matches min_dist
	#if is_colliding() and ray_origin.distance_to(col_point) > min_dist:
		#print("i am ray %s" %name + " and i can extend bc my dist to %s" %col_point + " is: %s" %ray_origin.distance_to(col_point))
		#extend = true
	## if it doesnt have a col (that matches min_dist) then it cannot extend
	#else:
		#extend = false
	#return extend
	#
#func _physics_process(_delta: float) -> void:
	## computing in GLOBAL
	## just the ray origin and its target based on max_length and direction
	#var target_global : Vector2 = ray_origin + direction_vector * preview_length
	#target_position = to_local(target_global)
	#
	#force_raycast_update()
	#if is_colliding():
		#col_point = get_collision_point()
		#
	## render move-able dir arrow/sprite
	#if can_i_extend():
		#arrow_sprite.visible = true
	#else: 
		#arrow_sprite.visible = false

extends Line2D
@onready var line_2d: Line2D = $"."

var pts = []
var player_in_area
var segments_in_area
var collider_in_area

func _ready():
	segments_in_area = []
	pts = points # assign points var (PackedVector2Arr)
	inst_collisions() # instantiate collision shape from inspector defined curve

# line2D collision: https://kidscancode.org/godot_recipes/4.x/2d/line_collision/index.html

func inst_collisions():
	for i in points.size() - 1:
		# need 2 define ST_BODY for 'solid' collisions and AREA for overlap detection 
		var new_shape_static = CollisionShape2D.new()
		var new_shape_area = CollisionShape2D.new()
		
		# defining area2D shape with more thickness than static_body for better overlap detection
		var rect = RectangleShape2D.new()
		new_shape_area.position = (points[i] + points[i + 1]) / 2
		new_shape_area.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, width / 2)
		new_shape_area.shape = rect
		$LineArea2D.add_child(new_shape_area)

		# defining static_body simply along vertices
		$LineStaticBody2D.add_child(new_shape_static)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape_static.shape = segment
		
func update_collisions():
	var static_body = $LineStaticBody2D
	var area = $LineArea2D
	# however many points there, there must be p-1 segments
	# connecting 2 points to each other...
	var needed_segment_count = maxi(points.size() - 1, 0)

	# reuse existing shapes, create only what's missing
	for i in needed_segment_count:
		var cshape_node_static: CollisionShape2D
		var cshape_node_area: CollisionShape2D
		# if there are more shapes
		if i < static_body.get_child_count():
			cshape_node_static = static_body.get_child(i)
			cshape_node_area = area.get_child(i)
		else:
			cshape_node_static = CollisionShape2D.new()
			cshape_node_area = CollisionShape2D.new()
			static_body.add_child(cshape_node_static)
			area.add_child(cshape_node_area)

		# static: collision
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		cshape_node_static.shape = segment
		
		# area: overlap
		var rect = RectangleShape2D.new()
		cshape_node_area.position = (points[i] + points[i + 1]) / 2
		cshape_node_area.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, width / 2)
		cshape_node_area.shape = rect

	# free any leftover shapes beyond what's needed_segment_count
	while static_body.get_child_count() > needed_segment_count:
		var static_shape = static_body.get_child(static_body.get_child_count() - 1)
		static_body.remove_child(static_shape)
		static_shape.queue_free()
		var area_shape = area.get_child(area.get_child_count() - 1)
		area.remove_child(area_shape)
		area_shape.queue_free()
			
#func _process(_delta):
	#if player_in_area:
		## only accept Q/E inputs when in radius of the vine...
		#if Input.is_action_just_pressed("interact"):
			## on click of E, remove some point
			#pts.remove_at(1)
			#points = pts # update points, visuals and vertices
			#update_collisions()
#
		#if Input.is_action_just_pressed("rot_extend"):
			## on click of Q, add some point
			#pts.append(Vector2(randf_range(0, 200), randf_range(-10, -50)))
			#points = pts # update points, visuals and vertices
			#update_collisions()

# for player body detection
func _on_area_2d_body_entered(_body: Node2D) -> void:
	#print(body.name)
	pass

func _on_line_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	# converting points into global positions so we can check intersection with Area2Ds
	var space_state = get_world_2d().direct_space_state
	
	for i in range(0, points.size()-1):
		var global_pos = line_2d.to_global(points[i])
		var parameters = PhysicsPointQueryParameters2D.new()
		parameters.position = global_pos
		parameters.collide_with_areas = true
		parameters.collide_with_bodies = false
		parameters.collision_mask = 1
		
		# stores Area2Ds the current point intersects w/
		var current_point_intersections = space_state.intersect_point(parameters)
		
		for intersection in current_point_intersections:
			# compare the current _on_line_area_2d_area_shape_entered NODE (area) against point/intersected COLLIDER
			if intersection.collider == area:
				pts.remove_at(i)
				points = pts

	# update collision shapes to match new points
	call_deferred("update_collisions")

extends Line2D
var pts

func _ready():
	pts = points # assign points var (PackedVector2Arr)
	inst_collisions() # instantiate collision shape from inspector defined curve

# line2D collision: https://kidscancode.org/godot_recipes/4.x/2d/line_collision/index.html

func inst_collisions():
	for i in points.size() - 1:
		# need 2 define both st_body and area for overlap detection and 'solid' collisions
		var new_shape_static = CollisionShape2D.new()
		var new_shape_area = CollisionShape2D.new()
		
		# defining area2D shape with more thickness than static_body for better overlap detection
		var rect = RectangleShape2D.new()
		new_shape_area.position = (points[i] + points[i + 1]) / 2
		new_shape_area.rotation = points[i].direction_to(points[i + 1]).angle()
		var length = points[i].distance_to(points[i + 1])
		rect.extents = Vector2(length / 2, width / 2)
		new_shape_area.shape = rect
		$Area2D.add_child(new_shape_area)

		# defining static_body simply along vertices
		$StaticBody2D.add_child(new_shape_static)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape_static.shape = segment
		
	#print('points: ' + str(points.size()))
	#print('static body: ' + str($StaticBody2D.get_child_count()))

func update_collisions():
	var static_body = $StaticBody2D
	var area = $Area2D
	# however many points there, there must be p-1 segments
	# connecting 2 points to each other...
	var segment_count = maxi(points.size() - 1, 0)

	# reuse existing shapes, create only what's missing
	for i in segment_count:
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

	# free any leftover shapes beyond what's segment_count
	while static_body.get_child_count() > segment_count:
		var static_shape = static_body.get_child(static_body.get_child_count() - 1)
		static_body.remove_child(static_shape)
		static_shape.queue_free()
		var area_shape = area.get_child(area.get_child_count() - 1)
		area.remove_child(area_shape)
		area_shape.queue_free()
			
func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		# on click of E, remove some point
		pts.remove_at(1)
		points = pts # update points, visuals and vertices
		update_collisions()

	if Input.is_action_just_pressed("rot_extend"):
		# on click of Q, add some point
		pts.append(Vector2(randf_range(0, 200), randf_range(-10, -50)))
		points = pts # update points, visuals and vertices
		update_collisions()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		print("hello player")

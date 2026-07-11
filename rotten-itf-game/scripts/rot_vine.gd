extends Line2D
var pts
func _ready():
	print("readyyyy")
	pts = points # assign points var (PackedVector2Arr)
	inst_collisions() # instantiate collision shape from inspector defined curve

func inst_collisions():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$StaticBody2D.add_child(new_shape)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment
	print('points: ' + str(points.size()))
	print('static body: ' + str($StaticBody2D.get_child_count()))

func update_collisions():
	var static_body = $StaticBody2D
	# however many points there, there must be p-1 segments
	# connecting 2 points to each other...
	var segment_count = maxi(points.size() - 1, 0)

	# reuse existing shapes, create only what's missing
	for i in segment_count:
		var cshape_node: CollisionShape2D
		# if there are more shapes
		if i < static_body.get_child_count():
			cshape_node = static_body.get_child(i)
		else:
			cshape_node = CollisionShape2D.new()
			static_body.add_child(cshape_node)

		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		cshape_node.shape = segment

	# free any leftover shapes beyond what's segment_count
	while static_body.get_child_count() > segment_count:
		var c = static_body.get_child(static_body.get_child_count() - 1)
		static_body.remove_child(c)
		c.queue_free()
			
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

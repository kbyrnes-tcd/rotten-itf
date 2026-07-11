extends Line2D
var pts

func _ready():
	pts = points # assign points var (PackedVector2Arr)
	inst_collisions()
	
func inst_collisions():
	for i in points.size() - 1:
		var new_shape = CollisionShape2D.new()
		$StaticBody2D.add_child(new_shape)
		var segment = SegmentShape2D.new()
		segment.a = points[i]
		segment.b = points[i + 1]
		new_shape.shape = segment
	
func update_collisions():
	var new_shape
	if (points.size() > 1):
		for i in points.size() - 1:
			new_shape = $StaticBody2D.get_child(i)
			var segment = SegmentShape2D.new()
			segment.a = points[i]
			segment.b = points[i + 1]
			new_shape.shape = segment
	else:
		for segment in $StaticBody2D.get_children():
			$StaticBody2D.remove_child(segment)

func _process(_delta):
	if Input.is_action_just_pressed("interact"):
		# on click of E, remove points
		pts.remove_at(1)
		points = pts # update points (triggers setter, updates visuals)
		update_collisions()

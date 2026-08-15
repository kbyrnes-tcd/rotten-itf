#@tool
extends Line2D
@onready var line_2d: Line2D = $"."

var pts = []
var segments_in_area
var collider_in_area
var rest_points: PackedVector2Array
var wave_time := 0.0
var collision_timer:= 0.0
var wave_strength := 3.0
var wave_speed:= 2.0
var wave_frequency := 0.8

const ROT_DRESSING = preload("uid://dismh7ltsr7nx")
var scene

func _ready():
	scene = get_tree().current_scene
	# random width, curve, and wave param.s
	width = randi_range(10,20)
	wave_strength  = randf_range(1.5, 3.0)
	wave_speed = randf_range(1.0, 2.0)
	wave_frequency  = randf_range(0.3, 0.8)
	
	var curve = Curve.new()
	curve.add_point(Vector2(0.0, randf_range(0.0, 0.3)))
	curve.add_point(Vector2(randf_range(0.4, 0.6), randf_range(0.65, 0.8)))
	curve.add_point(Vector2(1.0, randf_range(0.0, 0.3)))
	
	set_rest_shape()
	
	width_curve = curve
	segments_in_area = []
	pts = points
	
	#call_deferred("inst_collisions") # instantiate collision shape from inspector defined curve

func _physics_process(delta: float) -> void:
	animate_tentacle(delta)
	#collision_timer += delta
	#if collision_timer > 0.1:
		#update_collisions()
		#collision_timer = 0

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

#func _on_line_area_2d_area_shape_entered(_area_rid: RID, area: Area2D, _area_shape_index: int, _local_shape_index: int) -> void:
	##print("rot touched", area.name)
	#if area.name == "LanternArea2D":
		#AudioManager.play_fx("shrink")
		#var space_state = get_world_2d().direct_space_state
		#var indices = [] # to store points within lantern-area; to later split at
		## converting points into global positions so we can check intersection with Area2Ds
		#for i in range(0, points.size()-1):
			#var global_pos = line_2d.to_global(points[i])
			#var parameters = PhysicsPointQueryParameters2D.new()
			#parameters.position = global_pos
			#parameters.collide_with_areas = true
			#parameters.collide_with_bodies = false
			#parameters.collision_mask = 255
			#
			## stores Area2Ds the current point intersects w/
			#var current_point_intersections = space_state.intersect_point(parameters)
			#
			#for intersection in current_point_intersections:
				##print(intersection.collider.name)
				## compare the current _on_line_area_2d_area_shape_entered NODE (area) against point/intersected COLLIDER
				#if intersection.collider == area:
					#indices.append(i)
		#
		## SPLITTING
		## account for splitting over a number of points rather than just one index
		#if indices.is_empty():
			#return
#
		#var first = indices[0]
		#var last = indices[indices.size() - 1]
		#var head = points.slice(0, first)
		#var tail = points.slice(last + 1, points.size())
		#
		##var points_in_area = points.slice(first, last+2)
		#
		#if tail.size() > 1:
			#add_vine(head)
		#if tail.size() > 1:
			#add_vine(tail)
		#
		#pts.clear()
		#points = pts
		#rest_points.clear()
#
		#call_deferred("update_collisions")

func add_vine(pts_slice: PackedVector2Array):
	#print("inst along" + str(pts_slice[0]) + " & " + str(pts_slice[pts_slice.size()-1]))
	var vine = ROT_DRESSING.instantiate()
	vine.get_child(0).points = pts_slice
	scene.add_child(vine)
	#call_deferred("queue_free")
	
func time_out_collision():
	$".".get_child(0).process_mode=Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(3.0).timeout
	$".".get_child(0).process_mode=Node.PROCESS_MODE_INHERIT
	
func set_rest_shape():
	rest_points = points.duplicate()
	
func animate_tentacle(delta):
	if rest_points.size() < 3:
		return
	
	wave_time += delta * wave_speed
	var animated_points := PackedVector2Array()
	
	for i in range(rest_points.size()):
		var point = rest_points[i]
		
		if i > 0:
			var direction = rest_points[i] - rest_points[i-1]
			var normal = direction.normalized().orthogonal()
			
			#stronger movement near tip
			var influence = float(i) / rest_points.size()
			
			var offset = sin(
				wave_time + i * wave_frequency
			) * wave_strength * influence
			
			point += normal * offset
		animated_points.append(point)
	points = animated_points

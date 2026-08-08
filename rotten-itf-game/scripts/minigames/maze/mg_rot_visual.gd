@tool
extends Line2D
class_name RotVisual
var rest_points : PackedVector2Array
var wave_time := 0.0
var collision_timer:= 0.0
@export var wave_strength := 3.0
@export var wave_speed:= 2.0
@export var wave_frequency := 0.8

func _process(delta):
	set_rest_shape()
	animate_tentacle(delta)

func set_rest_shape():
	rest_points = points.duplicate()

func animate_tentacle(delta):
	if rest_points.size() < 3:
		return
	
	wave_time += delta * wave_speed
	var animated_points := PackedVector2Array()
	
	for i in range(rest_points.size()):
		var point = rest_points[i]
		
		#keep root still
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

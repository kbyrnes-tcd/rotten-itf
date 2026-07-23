extends Node2D
var pts : PackedVector2Array = PackedVector2Array([])

func _ready() -> void:
	pts = $vine.points

#get direction from player - up,down,left,right
func get_snapped_direction() -> Vector2:
	var mouse_pos = get_global_mouse_position()
	var diff = mouse_pos - global_position
	var angle = diff.angle()
	var snapped_angle = snappedf(angle, PI/2.0)
	return Vector2(cos(snapped_angle), sin(snapped_angle)).round()

func _physics_process(_delta: float) -> void:
	var dir = get_snapped_direction()
	var preview_length = 200.0

	# computing in GLOBAL
	var ray_origin = $ray.global_position
	var target_global = ray_origin + dir * preview_length
	$ray.target_position = $ray.to_local(target_global)

	$ray.force_raycast_update()

	var preview_point_global = target_global
	if $ray.is_colliding():
		preview_point_global = $ray.get_collision_point()

	# converting to the vine local space for visual update
	pts[pts.size() - 1] = $vine.to_local(preview_point_global)
	$vine.points = pts

	if $ray.is_colliding() and Input.is_action_just_pressed("click"):
		pts.append($vine.to_local(preview_point_global))
		$vine.points = pts
		$ray.global_position = preview_point_global


func move(ray: RayCast2D):
	pass

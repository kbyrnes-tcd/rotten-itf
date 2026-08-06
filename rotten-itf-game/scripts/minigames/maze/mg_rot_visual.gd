@tool
extends Line2D
class_name RotVisual
# inspector
#@export var textures: Array[Texture2D] = []
#@export var random_seed: int = 0
#@export_group("Wave Motion")
### Perpendicular displacement. Too high destroys the IK targeting, too low looks stiff.
#@export_range(0.0, 5.0, 0.5) var wave_amplitude: float = 2.5
### Controls wavelength. Higher values create tighter, more frequent waves along the arm.
#@export_range(0.0, 5, 0.1) var wave_frequency: float = 2.0
### Animation speed multiplier. Independent from physics delta for artistic control.
#@export_range(0.0, 10.0, 0.1) var wave_speed: float = 3.0
#
## priv values
#var segments_in_area: Array
#var _wave_time: float = 0.0
#var _segments: Array[Vector2] = [] # the joint positions (global space), num__segments + 1 entries (base + one per segment tip)
#var _segment_lengths: Array[float] = [] # the target distance each consecutive pair of _segments should maintain
#
## public values/copies
#static var segment_texture_indices: Array[int] = []
#static var textures_copy: Array[Texture2D] = []
#static var rng = RandomNumberGenerator.new()
#
#func _ready():
	#segments_in_area = []
	#textures_copy = textures
	#rng.seed = random_seed
	#init_texture_indices()
	#queue_redraw()
#
#func init_texture_indices():
	#segment_texture_indices.clear()
	#if textures.is_empty():
		#return
	#for i in points.size():
		## defining arr mapping each line2D seg to a specific tex. 
		#print(i)
		#segment_texture_indices.append(rng.randi_range(0, textures.size()-1))
#
#static func update_texture_indices(pts : PackedVector2Array):
	## only assign new tex-indices for newly added segments, similar to update_col logic from prev. rot stuff
	#var needed_segment_count : int = pts.size()-1
	#
	#for i in needed_segment_count:
		#if i >= segment_texture_indices.size():
			#if textures_copy.is_empty():
				#segment_texture_indices.append(0)
			#else:
				#segment_texture_indices.append(rng.randi_range(0, textures_copy.size() - 1))
		#
		## trim texture indices until the shraank segment count
		#while segment_texture_indices.size() > needed_segment_count:
			#segment_texture_indices.remove_at(segment_texture_indices.size() - 1)
		#
		#RotVisual.new().queue_redraw() # need 2 instance within static func.
#
#func apply_wave_motion(delta: float) -> void:
	## No amplitude, no wave!! (╯°o°）╯︵ ┻━┻
	#if wave_amplitude <= 0.0:
		#return
#
	#_wave_time += delta * wave_speed
#
	#var total_length: float = 0.0
	#for length in _segment_lengths:
		#total_length += length
#
	#var accumulated_length: float = 0.0
	#for i in range(1, _segments.size()):
		#accumulated_length += _segment_lengths[i - 1]
#
		## Normalized position (0-1) along the arm determines wave phase offset
		#var t: float = accumulated_length / total_length
#
		#var vec: Vector2 = _segments[i] - _segments[i - 1]
		#var direction: Vector2 = vec.normalized()
		#var perpendicular: Vector2 = direction.orthogonal()
#
		## Phase combines time (animation) with position (traveling wave) ᶘ ◕ᴥ◕ᶅ
		#var wave_phase: float = _wave_time + t * wave_frequency * TAU
		#var wave_offset: float = sin(wave_phase) * wave_amplitude
		#_segments[i] += perpendicular * wave_offset
#
#func _physics_process(delta: float) -> void:
	#apply_wave_motion(delta)
	#queue_redraw()
#
#func _draw() -> void:
	#if textures.is_empty() or points.size() < 2:
		#return
#
	#var distance_along_line := 0.0  # for continuity in texturs
#
	#for seg_i in range(points.size() - 1):
		#var x := points[seg_i]
		#var y := points[seg_i + 1]
		#var seg_vector := y - x
		#var seg_len := seg_vector.length()
		#var angle := seg_vector.angle()
		##print(segment_texture_indices.size())
		#var tex := textures[segment_texture_indices[seg_i]]
		#var tex_w := float(tex.get_width())
		#var tex_h := float(tex.get_height())
#
		#draw_set_transform(x, angle, Vector2.ONE)
#
		#var local_x := 0.0
		#while local_x < seg_len:
			## where in the repeating-tile pattern this draw starts
			#var phase := fmod(distance_along_line, tex_w)
			#var draw_w : float = min(tex_w - phase, seg_len - local_x)  # MIN of remaining tile w or segment
			#var src_rect := Rect2(phase, 0, draw_w, tex_h)
			#var dst_rect := Rect2(Vector2(local_x, -width * 0.5), Vector2(draw_w, width))
			#draw_texture_rect_region(tex, dst_rect, src_rect)
			#local_x += draw_w
			#distance_along_line += draw_w
#
	#draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE) #reset

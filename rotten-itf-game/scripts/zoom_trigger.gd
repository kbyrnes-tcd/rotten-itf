extends Area2D

@export var zoom := true
@export var offset := false
@export var zoom_out_level: Vector2 = Vector2(0.6,0.6)
@export var y_offset : float = -80
@export var offset_duration := 1.5
@export var zoom_duration: float = 2.0

var camera: Camera2D = null
var default_zoom: Vector2
var default_y: float
var current_tween = null
#var default_limit_right: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		camera = body.get_node_or_null("Camera2D")
		if camera:
			default_zoom = camera.zoom
			default_y = camera.offset.y
			# zoom out and move up
			if current_tween:
				current_tween.kill()
			current_tween = create_tween()
			if offset: current_tween.tween_property(camera, "offset", Vector2(camera.offset.x, y_offset), offset_duration)
			if zoom: current_tween.tween_property(camera, "zoom", zoom_out_level, zoom_duration)

func _on_body_exited(body: Node2D):
	if body.has_method("collect") and camera:
		# revert zoom and offset
		current_tween = create_tween()
		if offset: current_tween.tween_property(camera, "offset", Vector2(camera.offset.x, default_y), offset_duration)
		if zoom: current_tween.tween_property(camera, "zoom", default_zoom, zoom_duration)
		await current_tween.finished
		camera = null


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

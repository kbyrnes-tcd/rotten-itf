extends CanvasLayer

@onready var label = $CenterContainer/LIOLabel
@onready var dark_frame = $DarkFrame

var current_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	label.autowrap_mode = TextServer.AUTOWRAP_WORD
	label.custom_minimum_size = Vector2(400, 0)
	dark_frame.visible = false
	label.modulate.a = 0.0
	dark_frame.modulate.a = 0.0

func _show_text(text: String, duration: float = 3.5, fade: float = 1.0, seq := false):
	dark_frame.visible = true

	if !seq:
		var in_tween = create_tween()
		await in_tween.tween_property(dark_frame, "modulate:a", 0.5, 0.5).finished

	if current_tween:
		current_tween.kill()

	label.text = text
	label.modulate.a = 1.0
	current_tween = create_tween()
	current_tween.tween_interval(duration)
	current_tween.tween_property(label, "modulate:a", 0.0, fade)

	if !seq:
		await current_tween.finished
		var out_tween = create_tween()
		await out_tween.tween_property(dark_frame, "modulate:a", 0.0, 1.0).finished
		dark_frame.visible = false

func show_sequence(lines: Array, duration: float = 3.5):
	dark_frame.visible = true
	dark_frame.modulate.a = 0.0
	var in_tween = create_tween()
	await in_tween.tween_property(dark_frame, "modulate:a", 0.5, 0.5).finished

	for line in lines:
		await _show_text(line, duration, 1.0, true)
		await current_tween.finished

	var out_tween = create_tween()
	await out_tween.tween_property(dark_frame, "modulate:a", 0.0, 1.0).finished
	dark_frame.visible = false

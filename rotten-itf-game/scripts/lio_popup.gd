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
	dark_frame.modulate.a = 0.5

func _show_text(text: String, duration: float = 3.0, fade: float = 1.0):
	dark_frame.visible = true
	if current_tween:
		current_tween.kill()
	
	label.text = text
	label.modulate.a = 1.0
	
	current_tween = create_tween()
	current_tween.tween_interval(duration)
	current_tween.tween_property(label, "modulate:a", 0.0, fade)
	current_tween.tween_callback(func(): dark_frame.visible = false)
		

func show_sequence(lines: Array, duration: float = 3.0):
	dark_frame.visible = true
	for line in lines:
		label.text = line
		label.modulate.a = 1.0
		if current_tween:
			current_tween.kill()
		current_tween = create_tween()
		current_tween.tween_interval(duration)
		current_tween.tween_property(label, "modulate:a", 0.0,1.0)
		await current_tween.finished
	dark_frame.visible = false

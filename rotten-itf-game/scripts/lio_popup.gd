extends CanvasLayer

@onready var label = $CenterContainer/LIOLabel

var current_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	label.modulate.a = 0.0

func _show_text(text: String, duration: float = 3.0, fade: float = 1.0):
	if current_tween:
		current_tween.kill()
	
	label.text = text
	label.modulate.a = 1.0
	
	current_tween = create_tween()
	current_tween.tween_interval(duration)
	current_tween.tween_property(label, "modulate:a", 0.0, fade)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

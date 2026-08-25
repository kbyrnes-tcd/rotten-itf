extends CanvasLayer

@onready var dark_frame = $DarkFrame
@onready var button: Button = $CenterContainer/HBoxContainer/Button
@onready var button_2: Button = $CenterContainer/HBoxContainer/Button2
var decision_made := false
var current_tween = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	dark_frame.visible = false
	dark_frame.modulate.a = 0.0
	button.visible = false
	button_2.visible = false

func show_buttons():
	dark_frame.visible = true
	dark_frame.modulate.a = 0.0
	var in_tween = create_tween()
	await in_tween.tween_property(dark_frame, "modulate:a", 0.5, 0.5).finished

	button.visible = true
	button_2.visible = true

func _on_button_pressed() -> void:
	decision_made = true
	print("cue cutscene")
	clear()

func clear():
	var out_tween = create_tween()
	await out_tween.tween_property(dark_frame, "modulate:a", 0.0, 1.0).finished
	self.visible = false

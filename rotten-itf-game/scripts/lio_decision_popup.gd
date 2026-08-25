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
	cutscene()
	clear()

func cutscene():
	var transition_manager = get_tree().get_first_node_in_group("transition_manager")
	if transition_manager and transition_manager.get_child(0):
		await transition_manager.play_rot_cutscene()
		transition_manager.fade_out()
		GameGlobals.load_level("scene_06_post_switch")

func clear():
	var out_tween = create_tween()
	out_tween.tween_property(dark_frame, "modulate:a", 0.0, 0.5)
	out_tween.tween_property(button, "modulate:a", 0.0, 0.5)
	out_tween.tween_property(button_2, "modulate:a", 0.0, 0.5)
	await out_tween.finished
	self.visible = false

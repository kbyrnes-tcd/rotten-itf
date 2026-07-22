extends Control
@onready var pause_menu: Control = $"."
@onready var color_rect: ColorRect = $ColorRect

func _ready() -> void:
	var tween = create_tween()	
	tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)

func resume():
	get_tree().paused = false
	var tween = create_tween()	
	tween.tween_property(color_rect, "modulate:a", 0.0, 0.67)
	pause_menu.visible = false

func pause():
	var tween = create_tween()	
	tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
	pause_menu.visible = true
	get_tree().paused = true
	
func _process(_delta):
	# for bringing up the pause menu in the first place
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		pause()
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		resume()

func _on_resume_pressed() -> void:
	resume()

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	pass # Replace with function body.

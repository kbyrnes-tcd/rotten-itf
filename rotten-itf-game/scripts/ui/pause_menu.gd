extends Control

func _process(_delta):
	# for bringing up the pause menu in the first place
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		GameGlobals.pause(true)
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		GameGlobals.resume(true)

func _on_resume_pressed() -> void:
	GameGlobals.resume(true)

func _on_settings_pressed() -> void:
	pass # Replace with function body.

func _on_quit_pressed() -> void:
	pass # Replace with function body.

extends Control

const HOVER_SPRITE = preload("res://assets/images/ui/button_pause.png")

@onready var resume_btn = $BorderBox/VBoxContainer/Resume
@onready var settings_btn = $BorderBox/VBoxContainer/Settings
@onready var quit_btn = $BorderBox/VBoxContainer/Quit

func _ready():
	_setup_hover(resume_btn)
	_setup_hover(settings_btn)
	_setup_hover(quit_btn)

func _setup_hover(btn: Button):
	var sprite = btn.get_node("HoverSprite")
	sprite.visible = false
	btn.mouse_entered.connect(func(): sprite.visible = true)
	btn.mouse_exited.connect(func(): sprite.visible = false)

func _process(_delta):
	if Input.is_action_just_pressed("pause"):
		if not GameGlobals.tree:
			return
	# for bringing up the pause menu in the first place
	if Input.is_action_just_pressed("pause") and !get_tree().paused:
		GameGlobals.pause(true)
	elif Input.is_action_just_pressed("pause") and get_tree().paused:
		GameGlobals.resume(true)

func _on_resume_pressed() -> void:
	GameGlobals.resume(true)

func _on_settings_pressed() -> void:
	pass

func _on_quit_pressed() -> void:
	get_tree().quit()

extends Control

#const HOVER_SPRITE = preload("res://assets/images/ui/button_pause.png")

#@onready var resume_btn = $BorderBox/VBoxContainer/MainButtons/Resume
#@onready var settings_btn = $BorderBox/VBoxContainer/MainButtons/Settings
#@onready var quit_btn = $BorderBox/VBoxContainer/MainButtons/Quit
@onready var main_btns = $BorderBox/VBoxContainer/MainButtons
@onready var settings_panel = $BorderBox/VBoxContainer/SettingsPanel
@onready var volume_slider = $BorderBox/VBoxContainer/SettingsPanel/HBoxContainer/VolumeSilder

func _ready():
	settings_panel.visible = false 
	_setup_hovers()
	volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(0))

func _setup_hovers():
	var buttons := get_tree().get_nodes_in_group("buttons")
	buttons.map(func(b): _setup_hover(b))

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
	main_btns.visible = false
	settings_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed():
	settings_panel.visible = false
	main_btns.visible = true

func _on_stuck_pressed() -> void:
	GameGlobals.resume()
	var current_level = GameGlobals.level_root.get_child(0).name
	GameGlobals.load_level(current_level)

func _on_refill_pressed() -> void:
	var player = get_tree().get_first_node_in_group("player")
	if player:
		for i in 5:
			player.inv.insert(player.GLOWWORM)

func _on_volume_silder_value_changed(value: float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))

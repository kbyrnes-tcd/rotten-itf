extends Control

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

func _on_begin_pressed() -> void:
	GameGlobals.start_new_game()

func _on_settings_pressed() -> void:
	main_btns.visible = false
	settings_panel.visible = true

func _on_quit_pressed() -> void:
	get_tree().quit()

func _on_back_pressed():
	settings_panel.visible = false
	main_btns.visible = true

func _on_volume_silder_value_changed(value: float) -> void:
	AudioManager.set_master_volume(value)

extends Control

@onready var inv: Inventory = preload("uid://bbfb2yem3oxv0")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

@onready var label: Label = $NinePatchRect/RHS/ActiveItemLabel
@onready var desc: Label = $NinePatchRect/RHS/ScrollContainer/Box/ActiveItemDesc
@onready var scroll_container: ScrollContainer = $NinePatchRect/RHS/ScrollContainer
var vbar
@onready var img_texture: TextureRect = $NinePatchRect/RHS/ActiveItemTexture

# onload: inventory is closed, load up images
func _ready() -> void:
	# whenever inventory.gd emits the update signal, we must call update_slots in here for ui
	inv.update.connect(update_slots)
	update_slots()
	label.text = ""
	vbar = scroll_container.get_v_scroll_bar()
	var style := StyleBoxFlat.new()
	style.bg_color = Color(0.502, 0.502, 0.502, 0.0)
	style.content_margin_left = 1.0
	style.content_margin_right = 1.0  #^ both for width

	vbar.add_theme_stylebox_override("grabber", style)
	vbar.add_theme_stylebox_override("scroll", style)
	
	if inv.slots[0].has_item(): 
		activate_slot(inv.slots[0])
	
# update item visuals via inv_ui_slot.gd>update func
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func close():
	if visible:
		visible = false;
		get_tree().paused = false
		clear_selection()
		AudioManager.play_os("ui_close")
	
func open():
	if !visible and !get_tree().paused:
		# dont open inv while paused...
		GameGlobals.pause()
		visible = true;
		AudioManager.play_os("ui_open")

func set_label(txt : String):
	label.text = txt

func set_desc(txt : String):
	desc.text = txt

func set_img(txt : Texture2D):
	img_texture.texture = txt

func clear_selection():
	label.text = ""
	desc.text = ""
	render_ui_twin = false
	ui_twin = null
	for i in range(inv.slots.size()):
		inv.slots[i].set_unactive()
	update_slots()

var render_ui_twin := false
var ui_twin

func activate_slot(slot : InvSlot):
	slot.set_active()
	set_label(slot.item.name)
	set_desc(slot.item.desc)
	set_img(slot.item.texture)
	# if the selected inv item has a ui_twin to render, call it on the GameManager
	if slot.item.ui_twin:
		render_ui_twin = true
		ui_twin = slot.item.ui_twin
	AudioManager.play_os("ui_select")
	update_slots()

func _process(_delta):
	if Input.is_action_just_pressed(("inv")):
		var _foo = close() if visible else open()

	if render_ui_twin and (Input.is_action_just_pressed("interact") or Input.is_action_just_pressed("click")):
		GameGlobals.load_letter_ui(ui_twin)
		AudioManager.play_os("ui_open")

	if visible:
		for i in range(0, 8):
			if inv.slots[i].has_item() and Input.is_action_just_pressed("inv_%d" % (i + 1)):
				clear_selection()
				activate_slot(inv.slots[i])
				update_slots()

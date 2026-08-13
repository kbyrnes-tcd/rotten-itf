extends Control

@onready var inv: Inventory = preload("uid://bbfb2yem3oxv0")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

@onready var label: Label = $NinePatchRect/Label

# onload: inventory is closed, load up images
func _ready() -> void:
	# whenever inventory.gd emits the update signal, we must call update_slots in here for ui
	inv.update.connect(update_slots)
	close()
	update_slots()
	label.text = ""
	
# update item visuals via inv_ui_slot.gd>update func
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func close():
	if visible:
		visible = false;
		visible = false;
	
func open():
	if !visible and !get_tree().paused:
		# dont open inv while paused...
		visible = true;
		visible = true;

func set_label(desc : String):
	label.text = desc

func clear_selection():
	label.text = ""
	for i in range(inv.slots.size()):
		inv.slots[i].set_unactive()

func activate_slot(slot : InvSlot):
	slot.set_active()
	set_label(slot.item.desc)
	# if the selected inv item has a ui_twin to render, call it on the GameManager
	if slot.item.ui_twin:
		GameGlobals.load_letter_ui(slot.item.ui_twin)

func _process(_delta):
	if Input.is_action_just_pressed(("inv")):
		var _foo = close() if visible else open()

	if visible:
		for i in range(0, 6):
			if inv.slots[i].has_item() and Input.is_action_just_pressed("inv_%d" % (i + 1)):
				clear_selection()
				activate_slot(inv.slots[i])
				update_slots()

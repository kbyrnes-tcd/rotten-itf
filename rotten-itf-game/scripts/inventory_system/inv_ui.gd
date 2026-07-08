extends Control

@onready var inv: Inventory = preload("uid://bbfb2yem3oxv0")
@onready var slots: Array = $NinePatchRect/GridContainer.get_children()

var is_open = false

# onload: inventory is closed, load up images
func _ready() -> void:
	# whenever inventory.gd emits the update signal, we must call update_slots in here for ui
	inv.update.connect(update_slots)
	close()
	update_slots()
	
# update item visuals via inv_ui_slot.gd>update func
func update_slots():
	for i in range(min(inv.slots.size(), slots.size())):
		slots[i].update(inv.slots[i])

func close():
	is_open = false;
	visible = false;
	
func open():
	is_open = true;
	visible = true;

func _process(_delta):
	if Input.is_action_just_pressed(("inv")):
		var _foo = close() if is_open else open() 

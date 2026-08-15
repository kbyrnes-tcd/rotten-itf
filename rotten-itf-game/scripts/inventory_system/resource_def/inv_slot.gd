extends Resource

class_name InvSlot

@export var item: InvItem #type of item
@export var amount: int #amount of said item
@export var active: bool #whether item is currently selected by user

func has_item() -> bool:
	return item != null and amount > 0

func get_active() -> bool:
	return active

func set_active():
	active = true
	return

func set_unactive():
	active = false
	return

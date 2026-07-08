extends Resource

class_name Inventory
signal update

@export var slots: Array[InvSlot]

func insert(item: InvItem):
	# inserting to correct slot
	# if slot for the current item exists, and it is not empty, increment
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		item_slots[0].amount += 1
	else:
		# find an empty slot to insert the item into
		var empty_slots = slots.filter(func(slot): return slot.item == null)
		if !empty_slots.is_empty():
			empty_slots[0].item = item
			empty_slots[0].amount = 1
	update.emit()

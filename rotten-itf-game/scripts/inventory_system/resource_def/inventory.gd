extends Resource

class_name Inventory
signal update

@export var slots: Array[InvSlot]

func has(item: InvItem) -> bool:
	# if slot for the current item exists, and it is not empty, true
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		return true
	else: return false

func count(item: InvItem) -> int:
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if item_slots.is_empty():
		return 0
	return item_slots[0].amount

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
	
func remove(item: InvItem):
	# remove from correct slot
	# if slot for the current item exists, and it is not empty, decrement
	var item_slots = slots.filter(func(slot): return slot.item == item)
	if !item_slots.is_empty():
		item_slots[0].amount -= 1
	# if decremented amount has come to be 0 just null-ify that slot
	if item_slots[0].amount == 0:
		item_slots[0].item = null
	update.emit()

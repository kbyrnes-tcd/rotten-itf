extends Panel

@onready var inv_ui: Control = $"../../.."
@onready var item_sprite: Sprite2D = $ItemSprite
@onready var amount_text: Label = $Label
var inv_slot : InvSlot

# called in inv_ui.gd to render visuals
func update(slot: InvSlot):
	if !slot.item:
		inv_slot = null
		item_sprite.visible = false;
		amount_text.visible = false;
	else:
		inv_slot = slot
		item_sprite.visible = true;
		item_sprite.texture = slot.item.texture;
		amount_text.visible = true;
		amount_text.text = str(slot.amount);
	if slot.get_active():
		$SlotSprite.modulate = Color.WHITE
	else: 
		$SlotSprite.modulate = Color.GRAY

func _on_mouse_entered() -> void:
	if inv_slot:
		inv_ui.clear_selection()
		inv_ui.activate_slot(inv_slot)
		inv_slot.set_active()

func _on_mouse_exited() -> void:
	if inv_slot:
		inv_ui.activate_slot(inv_slot)
		inv_slot.set_unactive()

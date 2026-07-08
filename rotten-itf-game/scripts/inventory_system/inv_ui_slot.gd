extends Panel

@onready var item_sprite: Sprite2D = $ItemSprite
@onready var amount_text: Label = $Label

# called in inv_ui.gd to render visuals
func update(slot: InvSlot):
	if !slot.item:
		item_sprite.visible = false;
		amount_text.visible = false;
	else:
		item_sprite.visible = true;
		item_sprite.texture = slot.item.texture;
		amount_text.visible = true;
		amount_text.text = str(slot.amount);

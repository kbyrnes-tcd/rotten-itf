extends Control
class_name LetterUI
@onready var label: Label = $Sprite2D/Label

func set_label(copy : String):
	label.text = copy

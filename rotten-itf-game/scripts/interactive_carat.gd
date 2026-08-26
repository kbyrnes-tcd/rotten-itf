extends Node2D
@onready var sprite_2d: Sprite2D = $Sprite2D
@export var unlocked_carat := true

func _ready():
	sprite_2d.visible = false

func show_carat():
	sprite_2d.visible = true
	
func hide_carat():
	sprite_2d.visible = false

func _on_area_2d_body_entered(body: Node2D) -> void:
	print(body.name)
	if body.name == "Player" and unlocked_carat:
		show_carat()

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.name == "Player" and unlocked_carat:
		hide_carat()

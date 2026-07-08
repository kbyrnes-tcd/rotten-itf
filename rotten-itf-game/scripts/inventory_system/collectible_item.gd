extends Node2D
@onready var area_2d: Area2D = $Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

@export var item : InvItem
#@export var texture : Texture2D
var player = null;

func _ready() -> void:
	$Sprite2D.texture = item.texture

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("collect"):
		player = body
		player.collect(item)
		queue_free()

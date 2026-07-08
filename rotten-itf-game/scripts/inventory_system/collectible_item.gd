extends Node2D
@onready var area_2d: Area2D = $Area2D

@export var item : InvItem
var player = null;

#func _ready() -> void:
	#print("i am a collectible item~" + item.name)

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("collect"):
		player = body
		player.collect(item)

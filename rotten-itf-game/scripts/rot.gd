extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_body_entered(_body: Node2D) -> void:
	var tween = create_tween()
	tween.tween_property(sprite_2d, "modulate:a", 0.0, 0.5)
	print("entered")
	tween.tween_callback(queue_free)	

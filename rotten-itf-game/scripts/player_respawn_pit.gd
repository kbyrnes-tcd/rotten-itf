extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.has_method("collect"):
		var current_level = GameGlobals.level_root.get_child(0).name
		GameGlobals.load_level(current_level)

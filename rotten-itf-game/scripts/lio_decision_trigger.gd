extends Node2D

func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	
func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		var lio_decision_manager = get_tree().get_first_node_in_group("lio_decision_manager")
		if lio_decision_manager:
			await lio_decision_manager.show_buttons()
		else:
			print("lio_decision_manager not found")

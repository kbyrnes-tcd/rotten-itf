extends Node2D

func _process(delta: float) -> void:
	if GameGlobals.cue_decision:
		var lio_decision_manager = get_tree().get_first_node_in_group("lio_decision_manager")
		if lio_decision_manager:
			await lio_decision_manager.show_buttons()
		else:
			print("lio_decision_manager not found")

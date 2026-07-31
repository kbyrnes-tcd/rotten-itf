extends Node2D
@export var graph: MazeData

func update_dir_arrows(active_node : String):
	if graph.get_valid_dirs(active_node).has("left"): $left_sprite.visible=true
	else: $left_sprite.visible=false
	if graph.get_valid_dirs(active_node).has("right"): $right_sprite.visible=true
	else: $right_sprite.visible=false
	if graph.get_valid_dirs(active_node).has("up"): $up_sprite.visible=true
	else: $up_sprite.visible=false
	if graph.get_valid_dirs(active_node).has("down"): $down_sprite.visible=true
	else: $down_sprite.visible=false

func _on_player_rot_active_node_changed(active_node : String) -> void:
	update_dir_arrows(active_node)
	return

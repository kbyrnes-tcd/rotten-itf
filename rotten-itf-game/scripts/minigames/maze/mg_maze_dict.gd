extends Resource
class_name MazeDict

@export var nodes: Dictionary = {
	"A": {
		"pos": Vector2(0,0),
		"edges": {"right": "B"}
	}
} # GET NODES FROM TOOL SCRIPTTTTTTT

func get_pos(node_id: String) -> Vector2:
	return nodes[node_id]["pos"]

func get_valid_dirs(node_id: String) -> Array:
	return nodes[node_id]["edges"].keys()

func get_next_node(node_id: String, dir: String) -> String:
	return nodes[node_id]["edges"].get(dir, "")

@tool
# this is a TOOL script to run in editor and asses marker2Ds to create path data...
extends Node2D
class_name MazeData

@export var rebuild: bool = false:
	set(value):
		# only in editor not at runtime..
		if Engine.is_editor_hint():
			graph_data = build_graph()
			print("graph rebuilt  w/ %s nodes." %graph_data.size())

@export var graph_data: Dictionary = {}

func get_pos(node_id: String) -> Vector2:
	return graph_data[node_id]["pos"]

func get_valid_dirs(node_id: String) -> Array:
	return graph_data[node_id]["edges"].keys()

func get_next_node(node_id: String, dir: String) -> String:
	return graph_data[node_id]["edges"].get(dir, "")

#func get_fin_node(node_id: String) -> Array:
	#return node w/ flag fin

func build_graph() -> Dictionary:
	var nodes := {}
	for marker in get_children():
		nodes[marker.name] = { 
			"pos": marker.global_position, 
			"edges": {}, 
			# init dist for neighbors as some max-value
			"dist": {
				"left": Vector2(99999, 99999),
				"right": Vector2(99999, 99999),
				"up": Vector2(99999, 99999),
				"down": Vector2(99999, 99999)
			} 
		}

	var space_state = get_world_2d().direct_space_state
	for x in get_children():
		for y in get_children():
			if x == y: continue
			# store direction of edge dep. on vertical/horizontal difference
			var cur_dist : Vector2 = y.global_position - x.global_position
			var dir = ""
			
			if cur_dist.x == 0: # horizontally aligned
				if cur_dist.y > 0 && cur_dist.y:
					dir = "down"
				elif cur_dist.y < 0 && cur_dist.y:
					dir = "up"
					
			elif cur_dist.y == 0: # vertically aligned
				if cur_dist.x > 0 && cur_dist.x:
					dir = "right"
				elif cur_dist.x < 0 && cur_dist.x:
					dir = "left"
			else:
				print("in else case for some reason...")
				continue
	
			# ONLY ADD TO EDGES IF...
			# x,y are closer than what is already in nodes[x.name]["edges"][dir]
			# & NO collision via rayquery
			var query = PhysicsRayQueryParameters2D.create(x.global_position, y.global_position)
			var result = space_state.intersect_ray(query)
			if result.is_empty() && cur_dist < nodes[x.name]["dist"][dir]:
				# only record edge in array if there was NO intersection!
				nodes[x.name]["edges"][dir] = y.name
				nodes[x.name]["dist"][dir] = cur_dist
	return nodes

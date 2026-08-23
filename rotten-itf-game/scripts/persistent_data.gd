extends Node
class_name PersistentData
@export var objects : Array[Node2D]
@export_category("Parameters")
@export var track_position : bool
@export var track_freed : bool = true
var object_names : Array[String] = []
var spawnable_scenes: Dictionary = {}  # NAME AND OBJ's PRELOAD/PACKED SCENE

func _ready() -> void:
	for obj in objects:
		object_names.append(obj.name)

func add_obj(new_obj):
	if new_obj in objects:
		return
	objects.append(new_obj)
	object_names.append(new_obj.name)

func add_spawned_obj(new_obj: Node, obj_scene: PackedScene):
	if new_obj in objects:
		return
	objects.append(new_obj)
	object_names.append(new_obj.name)
	spawnable_scenes[new_obj.name] = obj_scene

func get_persistable(node: Node) -> Node:
	# for the vines we have node2d>line2d and we want line2d data so unwrapping to get 0th child...
	if node.has_method("get_persist_data"): # attached to rot_vine
		return node
	if node.get_child_count() > 0 and node.get_child(0).has_method("get_persist_data"):
		return node.get_child(0)
	return node

func save_state() -> Dictionary:
	var data := {}
	for i in objects.size():
		var obj := objects[i]
		var obj_name := object_names[i]
		var still_present := is_instance_valid(obj) and obj.is_inside_tree()
		var entry := {}
		
		if track_freed:
			entry["freed"] = !still_present
		if still_present:
			if track_position:
				entry["position"] = obj.global_position
			# custom stuff
			var target := get_persistable(obj)
			if target.has_method("get_persist_data"):
				entry["custom"] = target.get_persist_data() # -- custom stuff taken from the obj's own persist data, e.g. rot_vine's
		if spawnable_scenes.has(obj_name):
			entry["scene_path"] = spawnable_scenes[obj_name].resource_path
		data[obj_name] = entry
	return data

func load_state(data: Dictionary) -> void:
	for i in objects.size():
		var obj := objects[i]
		var obj_name := object_names[i]
		if !data.has(obj_name):
			continue
		var entry: Dictionary = data[obj_name]
		if entry.get("freed", false) and is_instance_valid(obj):
			obj.queue_free()
			continue
		if entry.has("position") and is_instance_valid(obj):
			obj.global_position = entry["position"]
		if entry.has("custom") and is_instance_valid(obj):
			var target := get_persistable(obj)
			if target.has_method("apply_persist_data"):
				target.apply_persist_data(entry["custom"])

	# FOR DYNAMIC OBJECTS...
	# instantiate by getting packedscene from entry["scene_path"], add to tree, restore pos/custom data, and register via add_obj
	for obj_name in data.keys():
		if obj_name in object_names:
			continue
		var entry: Dictionary = data[obj_name]
		if entry.get("freed", false):
			continue
		# CUSTOM params
		if entry.has("scene_path"):
			var ps: PackedScene = load(entry["scene_path"])
			var inst = ps.instantiate()
			inst.name = obj_name
			get_parent().add_child(inst)
			if entry.has("position"):
				inst.global_position = entry["position"]
			if entry.has("custom"):
				var target := get_persistable(inst)
				if target.has_method("apply_persist_data"):
					target.apply_persist_data(entry["custom"])
			add_spawned_obj(inst, ps)

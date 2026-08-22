extends Node
class_name PersistentData

@export var objects : Array[Node2D]
@export_category("Parameters")
@export var track_position : bool
@export var track_freed : bool

var object_names : Array[String] = []

func _ready() -> void:
	for obj in objects:
		object_names.append(obj.name)

func save_state() -> Dictionary:
	var data := {}
	for i in objects.size():
		var obj := objects[i]
		var obj_name := object_names[i]
		var still_present := is_instance_valid(obj) and obj.is_inside_tree()
		var entry := {}
		
		# store tracked params. in data
		if track_freed:
			entry["freed"] = !still_present
		if track_position and still_present:
			entry["position"] = obj.global_position
		data[obj_name] = entry
	return data

func load_state(data: Dictionary) -> void:
	print("IN LOAD STATE")
	for i in objects.size():
		var obj := objects[i]
		var obj_name := obj.name
		if !data.has(obj_name):
			continue
		var entry: Dictionary = data[obj_name]
		
		# if obj has been free'd in save state, persist that
		if entry.get("freed", false):
			obj.queue_free()
			continue
		# if obj has stored pos in save state, persist that
		if entry.has("position"):
			obj.global_position = entry["position"]

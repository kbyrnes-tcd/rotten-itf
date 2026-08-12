class_name DebugOverlay
extends CanvasLayer

# A simple debug overlay to monitor variables
# src: https://godotengine.org/asset-library/asset/645

var _monitors = {}
var _monitors_sequence:= 0 
var setget := 0 
@export var d_visible := true

func set_d_visible(value):
	d_visible = value
	if not d_visible:
		$Label.text = ""

func get_d_visible():
	return d_visible

func add_monitor(label: String, caller: Node, target: NodePath, call_method: String = "", args: Array = []) -> int:
	_monitors_sequence += 1

	if target.is_empty():
		_monitors[_monitors_sequence] = [label, caller, "", call_method, args]
	else:
		var target_node = caller.get_node(target)
		var property_path = ":" + target.get_concatenated_subnames()
		_monitors[_monitors_sequence] = [label, target_node, property_path, call_method, args]

	return _monitors_sequence


func remove_monitor(id: int) -> bool:
	var result = _monitors.has(id)
	if result:
		_monitors.erase(id)

	return result


func get_sequence():
	return _monitors_sequence


func format_label(label, value):
	return "{0}: {1}\n".format([label, value])


func process_monitor(monitor) -> String:
	var label = monitor[0]
	var node = monitor[1]

	if node and weakref(node).get_ref():
		if monitor[2] != "":
			var property = node.get_indexed(monitor[2])
			if monitor[3] == "":
				return format_label(label, property)
		return format_label(label, node.callv(monitor[3], monitor[4]))

	return ""


func _process(delta):
	if d_visible:
		var label_text = ""

		label_text += format_label("FPS", Engine.get_frames_per_second())
		label_text += format_label("Static Memory", String.humanize_size( OS.get_static_memory_usage()))
		label_text += format_label("Peak Static Memory", String.humanize_size( OS.get_static_memory_peak_usage()))
		label_text += format_label("Audio latency", AudioServer.get_output_latency())
		label_text += format_label("Object count", Performance.get_monitor(Performance.OBJECT_COUNT))
		label_text += format_label("Leaked node count", Performance.get_monitor(Performance.OBJECT_ORPHAN_NODE_COUNT))

		for id in _monitors:
			label_text += process_monitor(_monitors[id])
		$Label.text = label_text

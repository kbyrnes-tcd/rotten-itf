extends Node
class_name GameGlobals

static var level_prog = ["Begin", "Scene_01", "Scene_02"]
static var level_root: Node2D
var debug : bool = true

func _ready() -> void:
	var scene = get_tree().current_scene
	level_root = scene.get_node("World/LevelRoot")

	var debug_node : Node = scene.get_node_or_null("DebugConfig") if debug else null
	if debug_node == null:
		print("no debug")
		load_level(level_prog[1]) # AUTOLOAD SCENE_01
	else:
		print("opening debug")
		var debug_scene : PackedScene = debug_node._debug_level
		if debug_scene == null:
			push_warning("DebugConfig found but _debug_level is unset")
			load_level(level_prog[1]) # AUTOLOAD SCENE_01 IF DIDN'T SET DEBUG_LVL CORRECTLY
		else:
			level_root.add_child(debug_scene.instantiate())

static func unload_minigame():
	print("unloading minigameeeeee")
	return
	
static func load_minigame():
	print("loading minigameeeeee")
	return

static func unload_level():
	if level_root.get_child_count() > 0:
		level_root.remove_child(level_root.get_child(0))

static func load_level(level_name: String):
	unload_level()
	var path = "res://scenes/levels/%s.tscn" % level_name
	var scene : PackedScene = load(path)
	var scene_node : Node = scene.instantiate()
	if (scene):
		level_root.add_child(scene_node)

static func next_level():
	var curr_index : int = level_prog.find(level_root.get_child(0).name)
	var next_scene : String = str(level_prog[curr_index+1])
	load_level(next_scene)

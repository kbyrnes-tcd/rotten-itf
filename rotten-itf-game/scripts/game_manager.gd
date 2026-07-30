extends Node
class_name GameManager

static var level_prog = ["Begin", "Scene_01", "Scene_02"]
static var level_root: Node2D
@export var _debug_level: PackedScene

func _ready() -> void:
	level_root = get_node("World/LevelRoot")
	if !_debug_level:
		load_level(level_prog[1]) # AUTOLOAD SCENE_01
	else:
		level_root.add_child(_debug_level.instantiate()) # DEBUG STATE

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

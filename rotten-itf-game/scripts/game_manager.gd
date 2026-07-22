extends Node
static var level_prog = ["Begin", "Scene_01", "Scene_02"]
static var level_root: Node2D

func _ready() -> void:
	level_root = get_node("World/LevelRoot")
	load_level(level_prog[1]) # AUTOLOAD SCENE_00

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

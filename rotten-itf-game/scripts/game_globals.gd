extends Node
class_name GameGlobals

static var level_prog = ["Begin", "Scene_01", "Scene_02"]
static var level_root: Node2D
static var mg_root: Node2D
static var scene
static var tree
static var config : Node
#static var tween
enum Minigame { NONE, MAZE, LETTER }
#static var current_mg

static var pause_menu: Control
static var color_rect: ColorRect

var running_another_scene : bool = true # for running minigames and etc.

func _ready() -> void:
	if !running_another_scene:
		tree = get_tree()
		scene = tree.current_scene
		level_root = scene.get_node("World/LevelRoot")
		mg_root = scene.get_node("MinigameLayer/MgRoot")
		#current_mg = Minigame.NONE
		
		config = scene.get_node("Config")
		pause_menu = config.pause_menu
		var debug_scene : PackedScene = config.debug_level
		#tween = create_tween()
		#tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
		
		if debug_scene == null:
			load_level(level_prog[1])
		else:
			level_root.add_child(debug_scene.instantiate())

static func resume(w_menu : bool):
	tree.paused = false
	#tween.tween_property(color_rect, "modulate:a", 0.0, 0.67)
	if w_menu:
		pause_menu.visible = false

static func pause(w_menu : bool):
	#tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
	if w_menu:
		pause_menu.visible = true
	tree.paused = true

static func unload_minigame():
	print("unloading...")
	# resume game
	resume(false)
	# unload mg_root child from tree
	var c_mg : Node = mg_root.get_child(0)
	c_mg.queue_free()
	return
	
static func load_minigame(mg : int):
	pause(false)
	var inst : Node2D
	match mg:
		Minigame.MAZE:
			inst = config.maze_mg.instantiate()
	mg_root.add_child(inst)
	#inst.scale = Vector2(0.7, 0.7)
	#inst.position = tree.root.size / 2 

static func unload_level():
	if level_root.get_child_count() > 0:
		level_root.remove_child(level_root.get_child(0))

static func load_level(level_name: String):
	unload_level()
	var path = "res://scenes/levels/%s.tscn" % level_name
	var c_scene : PackedScene = load(path)
	var scene_node : Node = c_scene.instantiate()
	if (c_scene):
		level_root.add_child(scene_node)

static func next_level():
	var curr_index : int = level_prog.find(level_root.get_child(0).name)
	var next_scene : String = str(level_prog[curr_index+1])
	load_level(next_scene)

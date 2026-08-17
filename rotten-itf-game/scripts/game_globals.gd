extends Node
class_name GameGlobals

static var level_prog = ["Scene_01", "Scene_02_int", "Scene_02_ext", "Scene_03", "Scene_05"]
static var prog_counter := 0
# PROGRESSION: ext_path, garden_int, garden_ext, altar, quarters, tower, p-altar, underworld
static var audio_prog := [
	{"ambience": "Ext_Ambiance","music": "Temple_Music"}, #ext_path
	{"ambience": "Int_Ambiance","music": "Temple_Music"}, #garden_int
	{"ambience": "Garden_Ambience", "music": "Temple_Music"}, #garden_ext
	{"ambience": "Int_Ambiance", "music": "Temple_Music"}, #test
	{"ambience": "Int_Ambiance", "music": "Temple_Music"} #test
	#{"ambience": "", "music": ""}
]

static var level_root: Node2D
static var mg_root: Node2D
static var scene
static var tree
static var config: Node
# static var tween
enum Minigame { NONE, MAZE, LETTER }
static var current_mg
static var player : Player
static var pause_menu: Control
static var color_rect: ColorRect
static var letter_ui: Control

static var mid_mg : Node
static var inv_ui : Control
var running_another_scene : bool = false # for running minigames and etc.

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	tree = get_tree()
	scene = tree.current_scene
	player = scene.find_child("Player")
	if !running_another_scene:
		level_root = scene.get_node("World/LevelRoot")
		mg_root = scene.get_node("MinigameLayer/MgRoot")
		letter_ui = scene.get_node("HUD/LetterHUD/LetterUI")
		inv_ui = scene.get_node("HUD/InvHUD/InvUI")
		current_mg = Minigame.NONE
		
		config = scene.get_node("Config")
		pause_menu = config.pause_menu
		var debug_scene : PackedScene = config.debug_level
		#tween = create_tween()
		#tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
		
		if debug_scene == null:
			load_level(level_prog[0])
		else:
			var debug_node := debug_scene.instantiate()
			level_root.add_child(debug_node)
			player = debug_node.find_child("Player")

func _process(_delta: float) -> void:
	# esc button closes letter pop_ups and inventory, and exits minigames
	if Input.is_action_just_pressed("esc"):
		if letter_ui.visible:
			letter_ui.visible = false
		elif current_mg != Minigame.NONE:
			unload_mid_minigame()
		elif inv_ui.visible:
			inv_ui.close()

static func resume(w_menu : bool):
	# only resume if currently not in minigame
	if current_mg == Minigame.NONE:
		tree.paused = false
	#tween.tween_property(color_rect, "modulate:a", 0.0, 0.67)
	if w_menu:
		pause_menu.visible = false

static func pause(w_menu : bool):
	#tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
	if w_menu:
		pause_menu.visible = true
	tree.paused = true

static func unload_mid_minigame():
	#print("Tryna unload mid mg")
	#AudioManager.decrease_music_vol()
	current_mg = Minigame.NONE
	resume(false)
	# store mg_root child from tree into mid_mg
	mid_mg = mg_root.get_child(0)
	mg_root.get_child(0).process_mode = Node.PROCESS_MODE_DISABLED
	mg_root.get_child(0).visible = false
	return

static func unload_minigame():
	print("player has won, unloading fr")
	AudioManager.play_os_from_arr("win")
	#AudioManager.decrease_music_vol()
	current_mg = Minigame.NONE
	resume(false)
	# unload mg_root child from tree
	var c_mg := mg_root.get_child(0)
	var mg_spawner : ItemConsumer = level_root.get_child(0).get_child(0)
	# set minigame as complete: deactivate on item_consumer...
	mg_spawner.satisfied()
	c_mg.queue_free()
	mid_mg = null
	return
	
static func load_minigame(mg : int):
	#AudioManager.increase_music_vol()
	if inv_ui.visible or letter_ui.visible:
		inv_ui.close()
		letter_ui.visible = false
	pause(false)
	
	var inst : Node
	match mg:
		Minigame.MAZE:
			current_mg = Minigame.MAZE
			inst = config.maze_mg.instantiate()
		Minigame.LETTER:
			current_mg = Minigame.LETTER
			inst = config.letter_mg.instantiate()

	if mid_mg:
		# if player left mid_mg reload that
		mg_root.get_child(0).process_mode = Node.PROCESS_MODE_ALWAYS
		mg_root.get_child(0).visible = true
		mid_mg = null
		return
			
	mg_root.add_child(inst)
	
	if inst is Control:
		var viewport_size = tree.root.get_visible_rect().size
		inst.position = Vector2.ZERO
		inst.size = viewport_size
		var main_split = inst.get_node_or_null("MainSplit")
		if main_split:
			main_split.position = Vector2.ZERO
			main_split.size = viewport_size

static func load_letter_ui(letter : LetterCopy):
	letter_ui.visible = true
	letter_ui.set_label(letter.copy)

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
		player = scene_node.find_child("Player")
		if prog_counter != 0:
			print("Calling next audio in load_level")
			AudioManager.change_ambience(audio_prog[prog_counter].ambience)
			AudioManager.change_music(audio_prog[prog_counter].music)
		else: 
			print("Calling FIRST amb audio in load_level")
			AudioManager.play_ambience(audio_prog[0].ambience)
			AudioManager.play_music(audio_prog[0].music)

static func next_level():
	var curr_index : int = level_prog.find(level_root.get_child(0).name)
	var next_scene : String = str(level_prog[curr_index+1])
	prog_counter += 1
	load_level(next_scene)

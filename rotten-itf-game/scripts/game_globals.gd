extends Node
#class_name GameGlobals

var level_prog = ["scene_01", "scene_02_int", "scene_02_ext", "scene_03", "scene_04", "scene05", "scene07Underworld"]
var prog_counter := 0
# PROGRESSION: ext_path, garden_int, garden_ext, altar, quarters, tower, p-altar, underworld
var audio_prog := [
	{"ambience": "Ext_Ambiance","music": "Temple_Music"}, #ext_path
	{"ambience": "Int_Ambiance","music": "Temple_Music"}, #garden_int
	{"ambience": "Garden_Ambience", "music": "Temple_Music"}, #garden_ext
	{"ambience": "Int_Ambiance", "music": "Temple_Music"}, #test
	{"ambience": "Int_Ambiance", "music": "Temple_Music"} #test
	#{"ambience": "", "music": ""}
]

var level_root: Node2D
var mg_root: Node2D
var scene
var tree
var config: Node
# var tween
enum Minigame { NONE, MAZE, LETTER }
var current_mg
var player : Player
var pause_menu: Control
var color_rect: ColorRect
var letter_ui: Control

var mid_mg : Node
var inv_ui : Control
var running_another_scene : bool = true # for running minigames and etc.
var pending_start := false
static var dialogue_done: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if !running_another_scene:
		setup_game()

func setup_game():
	tree = get_tree()
	scene = tree.current_scene
	player = scene.find_child("Player")
	level_root = scene.get_node("World/LevelRoot")
	mg_root = scene.get_node("MinigameLayer/MgRoot")
	letter_ui = scene.get_node("HUD/LetterHUD/LetterUI")
	inv_ui = scene.get_node("HUD/InvHUD/InvUI")
	current_mg = Minigame.NONE
	config = scene.get_node("Config")
	pause_menu = config.pause_menu

	if pending_start:
		pending_start = false
		start_level_or_debug()

func start_level_or_debug() -> void:
	var debug_scene: PackedScene = config.debug_level
	if debug_scene == null:
		load_level(level_prog[0])
	else:
		AudioManager.play_music(audio_prog[0].music)
		AudioManager.play_ambience(audio_prog[0].ambience)
		var debug_node := debug_scene.instantiate()
		level_root.add_child(debug_node)
		player = debug_node.find_child("Player")

func start_new_game() -> void:
	pending_start = true
	get_tree().change_scene_to_file("res://scenes/levels/begin.tscn")

func _process(_delta: float) -> void:
	# esc button closes letter pop_ups and inventory, and exits minigames
	if Input.is_action_just_pressed("esc"):
		if letter_ui.visible:
			letter_ui.visible = false
		elif current_mg != Minigame.NONE:
			unload_mid_minigame()
		elif inv_ui.visible:
			inv_ui.close()

func resume(w_menu : bool = false):
	# only resume if currently not in minigame
	if current_mg == Minigame.NONE:
		tree.paused = false
	#tween.tween_property(color_rect, "modulate:a", 0.0, 0.67)
	if w_menu:
		pause_menu.visible = false

func pause(w_menu : bool = false):
	#tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
	if w_menu:
		pause_menu.visible = true
	tree.paused = true

func unload_mid_minigame():
	#print("Tryna unload mid mg")
	AudioManager.decrease_music_vol()
	current_mg = Minigame.NONE
	resume(false)
	# store mg_root child from tree into mid_mg
	mid_mg = mg_root.get_child(0)
	mg_root.get_child(0).process_mode = Node.PROCESS_MODE_DISABLED
	mg_root.get_child(0).visible = false
	return

func unload_minigame():
	print("player has won, unloading fr")
	AudioManager.play_os_from_arr("win")
	AudioManager.decrease_music_vol()
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
	
func load_minigame(mg : int):
	AudioManager.increase_music_vol()
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

func load_letter_ui(letter : LetterCopy):
	letter_ui.visible = true
	letter_ui.set_label(letter.copy)

func unload_level():
	if level_root.get_child_count() > 0:
		level_root.get_child(0).queue_free()

func load_level(level_name: String):
	level_name = level_name.to_lower()
	unload_level()
	var path = "res://scenes/levels/%s.tscn" % level_name
	var n_scene : PackedScene = load(path)
	var scene_node : Node = n_scene.instantiate()
	if (n_scene):
		level_root.add_child(scene_node)
		player = scene_node.find_child("Player")
		if prog_counter != 0:
			AudioManager.change_ambience(audio_prog[prog_counter].ambience)
			AudioManager.change_music(audio_prog[prog_counter].music)
		else: 
			AudioManager.play_ambience(audio_prog[0].ambience)
			AudioManager.play_music(audio_prog[0].music)

func next_level():
	prog_counter += 1
	var next_scene : String = str(level_prog[prog_counter])
	load_level(next_scene)

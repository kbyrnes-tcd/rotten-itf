extends Node

# just for audio prog now + starting off in-game audio (after start game&lore)
var level_prog = [
	"lore_scene",
	"scene_01", # Start path
	"scene_02_int", # Garden int
	"scene_02_ext", # Garden ext
	"scene_03", # Altar room,
	"scene_03_garden", # Mini garden
	"scene_04", # Chambers
	"scene05", # Tower
	"scene06", # P's altar room
	"scene07Underworld"
]
var prog_counter := 0
# PROGRESSION: ext_path, garden_int, garden_ext, altar, quarters, tower, p-altar, underworld
var audio_prog := {
	level_prog[0]: {"music": "Title_Song"},
	level_prog[1]: {"ambience": "Ext_Ambiance", "music": "Temple_Music"}, # Start path
	level_prog[2]: {"ambience": "Int_Ambiance", "music": "Temple_Music"}, # Garden int
	level_prog[3]: {"ambience": "Garden_Ambience", "music": "Temple_Music"}, # Garden ext
	level_prog[4]: {"ambience": "Int_Ambiance", "music": "Altar_Music"}, # Altar room
	level_prog[5]: {"ambience": "Garden_Ambience", "music": "Temple_Music"}, # Mini garden
	level_prog[6]: {"ambience": "Int_Ambiance", "music": "Temple_Music"}, # Chambers
	level_prog[7]: {"ambience": "Int_Ambiance", "music": "Temple_Music"}, # Tower
	level_prog[8]: {"ambience": "Int_Ambiance", "music": "Temple_Music"}, # P's altar room
	level_prog[9]: {"ambience": "Underworld_Ambience", "music": "Underworld_Music"} # Underworld
}

var prev_scene : String
var pending_spawn_door_id: String = ""

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
var pending_start := true
static var dialogue_done: bool = false
var previous_level: String = ""
static var return_position: Vector2 = Vector2.ZERO
static var first_rot_shot: bool = false

signal minigame_completed

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	AudioManager.play_music(audio_prog["lore_scene"].music)
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
		var debug_node := debug_scene.instantiate()
		level_root.add_child(debug_node)
		player = debug_node.find_child("Player")
		var debug_scene_name := debug_scene.resource_path.get_file().get_basename()
		AudioManager.change_music(audio_prog[debug_scene_name].music)

func start_new_game() -> void:
	pending_start = true
	get_tree().change_scene_to_file("res://scenes/levels/begin.tscn")

func _process(_delta: float) -> void:
	# esc button closes letter pop_ups and inventory, and exits minigames
	if Input.is_action_just_pressed("esc"):
		if letter_ui.visible:
			letter_ui.visible = false
			AudioManager.play_os("ui_close")
		elif current_mg != Minigame.NONE:
			unload_mid_minigame()
			AudioManager.play_os("ui_close")
		elif inv_ui.visible:
			AudioManager.play_os("ui_close")
			inv_ui.close()

func resume(w_menu : bool = false):
	# only resume if currently not in minigame
	if current_mg == Minigame.NONE:
		tree.paused = false
	#tween.tween_property(color_rect, "modulate:a", 0.0, 0.67)
	if w_menu:
		pause_menu.visible = false
		AudioManager.play_os("ui_close")

func pause(w_menu : bool = false):
	AudioManager.stop_walk_fx()
	#tween.tween_property(color_rect, "modulate:a", 0.5, 0.67)
	if w_menu:
		pause_menu.visible = true
		AudioManager.play_os("ui_open")
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
	var mg_spawner = get_tree().get_nodes_in_group("mg_spawner")
	if mg_spawner.size() > 0:
		mg_spawner[0].satisfied()
	c_mg.queue_free()
	# set minigame as complete: deactivate on item_consumer...
	mid_mg = null
	emit_signal("minigame_completed")
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
		# detach door node to keep it
		level_root.get_child(0).queue_free()

var game_audio_has_begun := false
func play_level_music(scene_name : String):
	var scene_index = level_prog.find(scene_name)
	print(scene_index, game_audio_has_begun)
	if scene_index == 1 and !game_audio_has_begun:
		game_audio_has_begun = true
		print("beginning game now w/ scene %s so gonna play ambi and decrease music vol." %scene_name)
		AudioManager.play_ambience(audio_prog[scene_name].ambience)
		AudioManager.decrease_music_vol(30)
		AudioManager.change_music(audio_prog[scene_name].music)
	elif scene_index > 1 and game_audio_has_begun:
		print("keep continue henceforth changing music n ambi")
		AudioManager.change_ambience(audio_prog[scene_name].ambience)
		AudioManager.change_music(audio_prog[scene_name].music)

var target_door
func load_level(level_name: String):
	level_name = level_name.to_lower()
	unload_level()
	var path = "res://scenes/levels/%s.tscn" % level_name
	var n_scene : PackedScene = load(path)
	var scene_node : Node = n_scene.instantiate()
	if (n_scene):
		level_root.add_child(scene_node)
		player = scene_node.find_child("Player")
		if pending_spawn_door_id != "":
			target_door = scene_node.find_child(pending_spawn_door_id)
		if target_door:
			player.global_position = target_door.global_position + Vector2(50, 0)
		pending_spawn_door_id = ""
		play_level_music(level_name)

#func load_scene(n_scene : PackedScene):
	#prog_counter+=1
	#var scene_node : Node = n_scene.instantiate()
	#if (n_scene):
		#unload_level()
		#level_root.add_child(scene_node)
		#player = scene_node.find_child("Player")
		#play_level_music(n_scene.resource_path.get_file().get_basename())

func prev_level():
	if previous_level != "":
		prog_counter -= 1
		load_level(previous_level)
	

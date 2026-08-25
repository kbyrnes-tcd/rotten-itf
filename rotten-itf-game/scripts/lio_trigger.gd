extends Node2D

@export var lio_text: String = ""
@export var display_duration: float = 3.5
@export var fade_duration: float = 1.0
@export var show_once: bool = true
@export var requires_dialogue_done: bool = false

@export var seq := false
@export var seq_text : Array[String]
@export var hades := false
var triggered = false
var body_in_range := false
var seq_active := false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	$Area2D.body_exited.connect(_on_body_exited)
	
	# add LIO obj to persistence tracker of c_tree
	var p_data : PersistentData = GameGlobals.get_current_tree_p_data()
	if p_data:
		p_data.add_obj(self)

func _process(_delta: float) -> void:
	if seq and body_in_range and not seq_active and Input.is_action_just_pressed("interact"):
		if hades:
			AudioManager.change_ambience(GameGlobals.audio_prog["cutscene"].ambience)
			AudioManager.change_music(GameGlobals.audio_prog["cutscene"].music)
		if show_once and triggered:
			#print("already showed one_shot lio")
			queue_free()
			return
		if requires_dialogue_done and not GameGlobals.dialogue_done:
			#print("come back when done w stuff")
			return
		var lio = get_tree().get_first_node_in_group("lio_manager")
		if lio:
			#print("pausing game and showing seq...")
			seq_active = true
			triggered = true
			GameGlobals.slow_player()
			await lio.show_sequence(seq_text, display_duration, hades)
			if hades: GameGlobals.cue_decision = true # cue dec AFTER HADES dialog lio is done
			GameGlobals.speed_player()
			queue_free()

func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		body_in_range = true
		if seq:
			return
		if show_once and triggered and !seq:
			queue_free()
			return
		if requires_dialogue_done and not GameGlobals.dialogue_done:
			return
		triggered = true
		_show_lio_text()

func _on_body_exited(body: Node2D):
	if body.has_method("collect"):
		body_in_range = false

func _show_lio_text():
	var lio_manager = get_tree().get_first_node_in_group("lio_manager")
	if lio_manager:
		await lio_manager._show_text(lio_text)
		queue_free()
	else:
		print("lio_manager not found")

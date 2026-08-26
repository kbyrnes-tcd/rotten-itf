extends Area2D

@export var next_scene_path : String
@export var door_id: String
@export var twin_id: String
@export var spawn_to_the_left : bool = false
@export var required_item: InvItem = null
@export var required_amount: int = 0
@export var interact_carat: Node2D
@export var has_minigame: bool = false
@export var crack := false
@export var minigame: GameGlobals.Minigame = GameGlobals.Minigame.MAZE
@export var blocking_rot: Array[Node2D] = []
@export var requires_minigame_complete: bool = false
@export var blocked_lio_text: String = ""
var minigame_solved: bool = false
var can_def_pass = false

var near_door = false
var player = null

func _ready() -> void:
	if GameGlobals.rotten_door == true:
		can_def_pass = true

enum Minigame { NONE, MAZE, LETTER }
#var minigame_completion
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	#print(blocking_rot.size())

	if near_door:
		var can_pass = _check_condtion() or can_def_pass # if can def pass, will pass...
		if interact_carat:
			if can_pass:
				interact_carat.show_carat()
			if can_pass and self.name == "DoorToTemple": GameGlobals.rotten_door = true
			else:
				interact_carat.hide_carat()
				
		if Input.is_action_just_pressed("interact"):
			var lio = get_tree().get_first_node_in_group("lio_manager")
			
			if has_minigame and minigame == GameGlobals.Minigame.LETTER and not minigame_solved and not GameGlobals.minigame_completion[minigame]:
				if required_item != null and player.inv.count(required_item) < required_amount:
					if lio:
						lio._show_text("Damn. I’m still missing pieces. I can’t make the writing out.", 3.0, 1.0)
					return
				else:
					#has all SCRAPS!!!
					if lio and not minigame_solved:
						lio._show_text("They’re all here. I can see her message. \nThere’s something strange about this letter… I have all the scraps, yet there’s still pieces missing.", 4.0, 1.0)
						await get_tree().create_timer(4.5).timeout
					
			if requires_minigame_complete and not GameGlobals.letter_minigame_complete:
				if lio and blocked_lio_text != "":
					lio._show_text(blocked_lio_text, 4.0, 1.0)
				return
			if not can_pass:
				return
			if !crack: AudioManager.play_os("open_door")
			# if the door has a minigame, load it if it hasn't been attempted or completed yet.
			if has_minigame and !minigame_solved and !GameGlobals.minigame_completion[minigame]:
				GameGlobals.load_minigame(minigame)
				await GameGlobals.minigame_completed
				minigame_solved = true
				GameGlobals.prev_scene = GameGlobals.get_current_level_tree().name
				GameGlobals.pending_spawn_door_id = twin_id
				GameGlobals.load_level(next_scene_path)
			else:
				GameGlobals.prev_scene = GameGlobals.level_root.get_child(0).name
				GameGlobals.pending_spawn_door_id = twin_id
				GameGlobals.load_level(next_scene_path)

func _check_condtion() -> bool:
	if required_item == null:
		return true
	
	if player and player.inv.count(required_item) < required_amount:
		return false
	
	for rot in blocking_rot:
		if is_instance_valid(rot):
			return false
	return true

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		near_door = true
		player = body
func _on_body_exited(_body: Node2D) -> void:
	near_door = false
	player = null
	if interact_carat:
		interact_carat.hide_carat()

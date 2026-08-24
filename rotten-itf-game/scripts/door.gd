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
var minigame_solved: bool = false

var near_door = false
var player = null

enum Minigame { NONE, MAZE, LETTER }
#var minigame_completion
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if near_door:
		var can_pass = _check_condtion()
		if interact_carat:
			if can_pass:
				interact_carat.show_carat()
			else:
				interact_carat.hide_carat()
		if can_pass and Input.is_action_just_pressed("interact"):
			if !crack: AudioManager.play_os("open_door")
			# if the door has a minigame, load it if it hasn't been attempted or completed yet.
			if has_minigame and !minigame_solved and !GameGlobals.minigame_completion[minigame]:
				GameGlobals.load_minigame(minigame)
				await GameGlobals.minigame_completed
				minigame_solved = true
				GameGlobals.prev_scene = GameGlobals.level_root.get_child(0).name
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

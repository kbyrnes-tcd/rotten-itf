extends Area2D

@export var next_scene_path : String
@export var door_id: String
@export var twin_id: String
@export var spawn_to_the_left : bool = false
@export var required_item: InvItem = null
@export var required_amount: int = 0
@export var interact_carat: Node2D
@export var has_minigame: bool = false
@export var minigame: GameGlobals.Minigame = GameGlobals.Minigame.MAZE
var minigame_solved: bool = false

var near_door = false
var player = null

#func _ready() -> void:
	#current_scene = GameGlobals.level_root.get_child(0).name.to_lower()

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
			AudioManager.play_os("open_door")
			if has_minigame and not minigame_solved:
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
	
	if player and player.inv.count(required_item) >= required_amount:
		return true
	return false

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		near_door = true
		player = body

func _on_body_exited(_body: Node2D) -> void:
	near_door = false
	player = null
	if interact_carat:
		interact_carat.hide_carat()

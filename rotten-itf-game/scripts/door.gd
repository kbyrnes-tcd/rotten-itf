extends Area2D

@export var next_scene = preload("uid://h1dqndhb88on")
@export var required_item: InvItem = null
@export var required_amount: int = 1
@export var interact_carat: Node2D
@export var has_minigame: bool = false
@export var minigame: GameGlobals.Minigame = GameGlobals.Minigame.MAZE
@export var go_back: bool = false
var minigame_solved: bool = false

var near_door = false
var player = null


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
			print("interact pressed")
			AudioManager.play_os("open_door")
			if go_back:
				print("going back")
				GameGlobals.prev_level()
			elif has_minigame and not minigame_solved:
				GameGlobals.load_minigame(minigame)
				await GameGlobals.minigame_completed
				minigame_solved = true
				GameGlobals.next_level()
			else:
				GameGlobals.next_level()

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

extends Node2D

@export var dialogue_lines: Array[String] = []
@export var speaker: String = ""
@export var one_shot: bool = true

var player_in_area = false
var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(on_body_entered)
	$Area2D.body_exited.connect(on_body_exited)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact"):
		if one_shot and triggered:
			return
		trigger_dialogue()
	
func trigger_dialogue():
	triggered = true
	var dialogue_manager = get_tree().get_first_node_in_group("dialogue_manager")
	if dialogue_manager:
		for line in dialogue_lines:
			dialogue_manager.queue_text(line, speaker)
	

func on_body_entered(body: Node2D):
	if body.has_method("collect"):
		player_in_area = true

func on_body_exited(body: Node2D):
	if body.has_method("collect"):
		player_in_area = false

extends Node2D

@export var dialogue_lines: Array[String] = []
@export var speaker: Array[String] = []
@export var one_shot: bool = true
@onready var hint = $Interact

var player_in_area = false
var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(_on_area_2d_body_entered)
	$Area2D.body_exited.connect(_on_area_2d_body_exited)


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
		for i in dialogue_lines.size():
			var speak = speaker[i] if i < speaker.size() else ""
			dialogue_manager.queue_text(dialogue_lines[i], speak)
	else:
		print("dialogue manager not found")

func _on_area_2d_body_entered(body: Node2D):
	if body.has_method("collect"):
		player_in_area = true
		hint.visible = true
		print("player in dialogue area")


func _on_area_2d_body_exited(body: Node2D):
	if body.has_method("collect"):
		player_in_area = false
		hint.visible = false

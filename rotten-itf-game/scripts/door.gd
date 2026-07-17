extends Area2D

@export var next_scene = preload("uid://h1dqndhb88on")
var near_door = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact") && near_door:
		print("opening door")
		get_tree().change_scene_to_packed(next_scene)

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		near_door = true

func _on_body_exited(body: Node2D) -> void:
	near_door = false

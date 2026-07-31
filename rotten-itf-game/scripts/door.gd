extends Area2D

@export var next_scene = preload("uid://h1dqndhb88on")
var near_door = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") && near_door:
		#print("opening door")
		GameGlobals.next_level()

func _on_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		near_door = true

func _on_body_exited(_body: Node2D) -> void:
	near_door = false

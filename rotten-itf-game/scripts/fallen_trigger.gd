extends Area2D

@export var chandelier: Node
var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_body_entered(body):
	print("body entered fallen trigger: " + str(body.name))
	if body.has_method("collect") and not triggered:
		triggered = true
		print("calling fall")
		chandelier.fall()

extends Area2D

var player_in_area = false
var pulled = false
@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var hint = $InteractHint
@export var chandelier: Node
@export var pulled_texture : Texture2D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if player_in_area and Input.is_action_just_pressed("interact") and not pulled:
		pulled = true
		print("lower chandelier")
		chandelier.lower()
		sprite_2d.texture = pulled_texture

func _on_body_entered(body):
	if body.has_method("collect"):
		player_in_area = true
		hint.visible = true
		
func _on_body_exited(body):
	if body.has_method("collect"):
		player_in_area = false
		hint.visible = false

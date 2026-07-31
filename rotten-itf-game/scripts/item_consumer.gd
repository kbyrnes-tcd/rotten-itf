extends Node2D

var player = null;
var player_in_area : bool = false;

@export var item : InvItem # the required item for this lantern/consumer object
@export var activated_tex : Texture2D

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var activated_sprite: Sprite2D = $Sprite2D/ActivatedSprite

func _ready() -> void:
	print("this lantern requires an " + item.name)

func _physics_process(_delta: float) -> void:
	if player_in_area && Input.is_action_just_pressed("interact"):
		if (player.has(item)):
				player.use(item)
				# item consumer is now 'satiated'
				call_deferred("deactivate")
		else:
			print("player does not have the req item")	

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.has_method("collect"):
		player = body
		player_in_area = true

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.has_method("collect"):
		player_in_area = false

# lantern specific visual stuff can change/remove
func deactivate():
	activated_sprite.texture = activated_tex
	collision_shape_2d.disabled = true
	GameGlobals.load_minigame(GameGlobals.Minigame.MAZE)

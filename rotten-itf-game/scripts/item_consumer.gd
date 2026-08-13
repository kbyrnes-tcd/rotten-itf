extends Node2D
class_name ItemConsumer

var player = null;
var player_in_area : bool = false;

@export var item : InvItem # the required item for this lantern/consumer object
@export var activated_tex : Texture2D
@export var minigame: GameGlobals.Minigame

@onready var collision_shape_2d: CollisionShape2D = $Area2D/CollisionShape2D
@onready var activated_sprite: Sprite2D = $Sprite2D/ActivatedSprite
var mid_minigame := false

#func _ready() -> void:
	#print("this lantern requires an " + item.name)

func _physics_process(_delta: float) -> void:
	# GameGlobals.current_mg = 0 = NONE, only take from player if there isn't a current_mg being run...
	if player_in_area and Input.is_action_just_pressed("interact"):
		if (player.has(item) and player.can_take_item(item)):
				#player.use(item) # comment out to not actually subtract from player inv
				print("hello")
				GameGlobals.load_minigame(minigame)
				mid_minigame = true
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
func satisfied():
	activated_sprite.texture = activated_tex
	collision_shape_2d.disabled = true

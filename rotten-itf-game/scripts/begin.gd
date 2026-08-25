extends Node2D
@onready var animation_player: AnimationPlayer = $Transition/RotCutscene/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameGlobals.setup_game()

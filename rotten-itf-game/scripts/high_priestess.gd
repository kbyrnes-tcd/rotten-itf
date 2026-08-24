extends Node2D

@onready var anim = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	anim.animation = "talking"
	anim.frame = 0
	anim.stop()

func start_talking():
	print("plauing animation")
	anim.play("talking")
	
func die():
	anim.play("dying")
	await anim.animation_finished
	anim.frame = 6


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

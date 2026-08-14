extends Node2D

enum State { HANGING, LOWERED, FALLEN}
var state = State.HANGING

@onready var anim = $AnimationPlayer


func lower():
	if state == State.HANGING:
		state = State.LOWERED
		# shake first then lower
		var original_pos = position
		var tween = create_tween()
		# shake left and right a few times
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x, 0.1)
		# then play lower animation after shake finishes
		tween.tween_callback(func(): anim.play("lower"))

func fall():
	if state == State.LOWERED:
		state = State.FALLEN
		var original_pos = position
		var tween = create_tween()
		# shake before falling
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x, 0.1)
		# then fall after shake
		tween.tween_property(self, "position:y", 2000.0, 2.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

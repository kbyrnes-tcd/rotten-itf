extends Path2D

@onready var path_follow: PathFollow2D = $PathFollow2D
	
func _process(_delta: float) -> void:
	if Input.is_action_pressed("left"):
		path_follow.progress_ratio -=0.0025
	if Input.is_action_pressed("right"):
		path_follow.progress_ratio +=0.0025

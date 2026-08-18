extends Node2D

@onready var sprite = $Sprite2D
@onready var light = $PointLight2D
@onready var area = $Area2D

signal amulet_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = false
	area.body_entered.connect(_on_body_entered)
	_glow_animation()

func show_amulet():
	visible = true
	_glow_animation()

func _glow_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(light, "energy", 1.5, 0.8)
	tween.tween_property(light, "energy", 0.5, 0.8)

func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		emit_signal("amulet_collected")
		queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

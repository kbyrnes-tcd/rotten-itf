extends Area2D

const GLOWWORM = preload("res://scripts/inventory_system/items/glow_worm.tres")

@export var amount: int = 5

@onready var light = $PointLight2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	var tween = create_tween().set_loops()
	tween.tween_property(light, "energy", 1.2, 1.0)
	tween.tween_property(light, "energy", 0.4, 1.0)


func _on_body_entered(body: Node2D):
	if body.has_method("collect") and visible:
		for i in amount:
			body.collect(GLOWWORM)
		visible = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

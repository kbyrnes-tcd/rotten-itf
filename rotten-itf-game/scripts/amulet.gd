extends Node2D

@onready var sprite = $Sprite2D
@onready var light = $PointLight2D
@onready var area = $Area2D

@export var blocking_rot: Array[Node2D] = []
@export var inv_amulet: InvItem

static var dialogue_done: bool = false

signal amulet_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	light.enabled = false
	area.body_entered.connect(_on_body_entered)

func glow_animation():
	GameGlobals.dialogue_done = true
	light.enabled = true
	var tween = create_tween().set_loops()
	tween.tween_property(light, "energy", 1.5, 0.8)
	tween.tween_property(light, "energy", 0.5, 0.8)

func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		var all_cleared = true
		for rot in blocking_rot:
			if is_instance_valid(rot):
				all_cleared = false
				break
		if not all_cleared:
			return
		emit_signal("amulet_collected")
		body.collect(inv_amulet)
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

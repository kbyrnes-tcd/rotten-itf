extends Node2D

@onready var sprite = $Sprite2D
@onready var light = $PointLight2D
@onready var area = $Area2D

@export var inv_lantern: InvItem

signal lantern_collected

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	visible = true
	light.enabled = true
	area.body_entered.connect(_on_body_entered)
	_glow_animation()

func _glow_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(light, "energy", 1.5, 0.8)
	tween.tween_property(light, "energy", 0.3, 0.8)
	
func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		emit_signal("lantern_collected")
		body.collect(inv_lantern)
		var lio = get_tree().get_first_node_in_group("lio_manager")
		if lio and not GameGlobals.first_lantern:
			GameGlobals.first_lantern = true
			lio.show_sequence([
				"A lantern. ",
				"Press I to open your inventory and see what you're carrying.",
				"Press [ to equip the lantern."
			], 3.0)
		queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

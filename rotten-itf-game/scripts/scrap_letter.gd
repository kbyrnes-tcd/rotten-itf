extends Area2D

const LETTER_SCRAP = preload("res://scripts/inventory_system/items/letter_scrap.tres")

@onready var light = $PointLight2D

func _ready():
	body_entered.connect(_on_body_entered)
	# pulsing glow
	var tween = create_tween().set_loops()
	tween.tween_property(light, "energy", 1.5, 0.8)
	tween.tween_property(light, "energy", 0.3, 0.8)

func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		body.collect(LETTER_SCRAP)
		# show count LIO
		var lio = get_tree().get_first_node_in_group("lio_manager")
		if lio:
			var count = body.inv.count(LETTER_SCRAP)
			var total = 7  # your total number of scraps
			lio._show_text(str(count) + "/" + str(total) + " letter scraps collected.", 2.0, 0.5)
		queue_free()

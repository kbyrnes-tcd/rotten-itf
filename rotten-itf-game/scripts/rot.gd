extends Area2D
@onready var sprite_2d: Sprite2D = $Sprite2D

func _on_body_entered(_body: Node2D) -> void:
	var tween = create_tween()	
	tween.tween_property(sprite_2d, "modulate:a", 0.0, 0.5)
	tween.tween_callback(queue_free)
	
	
	#--------SEGMENT ELIMINATION ------ #
	
	#extends Node2D
	#
	#func _ready():
		#for segment in get_children():
			#if segment is Area2D:
				#segment.body_entered.connect(func(body): on_segment_entered(body, segment))
				#
	#func _on_segment_entered(body: Node2D, segment: Area2D):
		##only clear if lantern touching rot --- NEED TO ADD CHECK
		#var sprite = segment.get_node("Sprite2D")
		#var tween = create_tween()
		#tween.tween_property(sprite, "modulate: a", 0.0, 0.5)
		#tween.tween_callback(segment.queue_free)
	#
	##if all segments eliminated - remove whole thing
	#await get_tree().create_timer(0.6).timeout
	#if get_child_count() == 0:
		#queue_free()

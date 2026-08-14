extends Node2D

enum State { HANGING, LOWERED, FALLEN}
var state = State.HANGING
var chain_links: Array = []
@onready var anim = $AnimationPlayer
@onready var chain = $Chain


func lower():
	if state == State.HANGING:
		state = State.LOWERED
		var original_pos = position
		var tween = create_tween()
		_grow_chain()
		#shake chandelier
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x, 0.1)
		tween.tween_callback(func(): 
			anim.play("lower"))
		
func _grow_chain():
	var timer = get_tree().create_timer(0.3)
	timer.timeout.connect(func():
		_add_chain_link()
		if chain_links.size() < 5:
			_grow_chain())
func _add_chain_link():
	var link = chain.duplicate()
	add_child(link)
	var link_height = chain.texture.get_height()
	link.position = Vector2(chain.position.x, chain.position.y - (chain_links.size() + 1) * link_height * 0.55)
	chain_links.append(link)
	
func fall():
	if state == State.LOWERED:
		state = State.FALLEN
		var original_pos = position
		var tween = create_tween()
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x + 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x - 5, 0.1)
		tween.tween_property(self, "position:x", original_pos.x, 0.1)
		tween.tween_property(self, "position:y", 2000.0, 2.5)\
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
		

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

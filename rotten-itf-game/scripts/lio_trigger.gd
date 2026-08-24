extends Node2D

@export var lio_text: String = ""
@export var display_duration: float = 3.0
@export var fade_duration: float = 1.0
@export var show_once: bool = true
@export var requires_dialogue_done: bool = false

var triggered = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area2D.body_entered.connect(_on_body_entered)
	
	# add LIO obj to persistence tracker of c_tree
	var p_data : PersistentData = GameGlobals.get_current_tree_p_data()
	if p_data:
		p_data.add_obj(self)

func _on_body_entered(body: Node2D):
	if body.has_method("collect"):
		if show_once and triggered:
			#print("freeing lio %s!" %lio_text)
			queue_free()
			return
		if requires_dialogue_done and not GameGlobals.dialogue_done:
			return
		triggered = true
		_show_lio_text()

func _show_lio_text():
	var lio_manager = get_tree().get_first_node_in_group("lio_manager")
	if lio_manager:
		lio_manager._show_text(lio_text)
	else:
		print("lio_manager not found")

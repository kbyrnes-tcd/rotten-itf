extends CanvasLayer


const CHAR_READ_RATE = 0.05

@onready var textbox_container = $MarginContainer
@onready var start_symbol = $MarginContainer/MarginContainer/HBoxContainer/start
@onready var end_symbol = $MarginContainer/MarginContainer/HBoxContainer/end
@onready var label = $MarginContainer/MarginContainer/HBoxContainer/dialogue

enum State{
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []
var current_tween = null

func _ready():
	hide_textbox()
	queue_text("Daphne help...")
	queue_text("I am here")
	queue_text("You are not responsbile")
	
func _process(delta):
	match current_state:
		State.READY:
			if text_queue.size() > 0:
				display_text()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				#skip to the end
				label.visible_ratio = 1.0
				if current_tween:
					current_tween.kill()
				end_symbol.text = "v"
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				if text_queue.size() == 0:
					hide_textbox()
					
func queue_text(next_text):
	text_queue.push_back(next_text)
	
func hide_textbox():
	start_symbol.text = ""
	end_symbol.text = ""
	label.text = ""
	textbox_container.hide()
	
func show_textbox():
	start_symbol.text = "*"
	textbox_container.show()

func display_text():
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_ratio = 0.0
	end_symbol.text = ""
	change_state(State.READING)
	show_textbox()
	#Create tween
	current_tween = create_tween()
	current_tween.tween_property(label, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE)
	current_tween.tween_callback(func():
		end_symbol.text = "v"
		change_state(State.FINISHED))
		
func change_state(next_state):
	current_state = next_state
	

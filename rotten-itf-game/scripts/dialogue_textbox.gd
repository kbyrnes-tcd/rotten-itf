extends CanvasLayer


const CHAR_READ_RATE = 0.05

@onready var textbox_container = $DialogueAnchor
@onready var character_name_label = $DialogueAnchor/NamePlate/HBoxContainer/CharacterName
@onready var label = $DialogueAnchor/DialogueBox/MarginContainer/VBoxContainer/DialogueText
@onready var continue_hint = $DialogueAnchor/DialogueBox/ContinueHint
@onready var portrait = $DialogueAnchor/PortraitLeft
@onready var portrait_right = $DialogueAnchor/PortraitRight

const PORTRAITS = {
	"Daphne" : preload("res://assets/images/player/daphne_animations/portrait/daphne.png"),
	"Persephone" : preload("res://assets/images/player/persephone/Persephone_HUD.png"),
	"Hades" : preload("res://assets/images/player/zeus_hades/darkenedPortrait.png"),
	"Zeus" : preload("res://assets/images/player/zeus_hades/darkenedPortrait.png")
}

const SPEAKER_SIDE = {
	"Daphne": "left",
	"Persephone": "right",
	"HighPriestess": "right",
	"Hades" : "right",
	"Zeus" : "left"
}

enum State{
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []
var current_tween = null

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide_textbox()
	#queue_text("Daphne help...", "Daphne")
	#queue_text("I am here" , "Persephone")
	#queue_text("You are not responsbile", "Daphne")
	
func _process(_delta):
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
				continue_hint.visible = true
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				change_state(State.READY)
				if text_queue.size() == 0:
					#print("DIALOG FINISHED!!!!!")
					GameGlobals.resume()
					AudioManager.decrease_music_vol(20.0)
					hide_textbox()
					
func queue_text(next_text: String, speaker: String = ""):
	text_queue.push_back({"text": next_text, "speaker": speaker})
	
func hide_textbox():
	label.text = ""
	character_name_label.text = ""
	continue_hint.visible = false
	portrait.visible = false
	textbox_container.hide()
	
func show_textbox(speaker: String = ""):
	character_name_label.text = speaker
	continue_hint.visible = false
	
	portrait.visible = false
	portrait_right.visible = false
	
	if PORTRAITS.has(speaker):
		var side = SPEAKER_SIDE.get(speaker, "left")
		if side == "left":
			portrait.texture = PORTRAITS[speaker]
			portrait.visible = true
			portrait.flip_h = false
		else:
			portrait_right.texture = PORTRAITS[speaker]
			portrait_right.visible = true
			portrait_right.flip_h = true

	textbox_container.show()

func display_text():
	var entry = text_queue.pop_front()
	var next_text = entry["text"]
	var speaker = entry["speaker"]
	AudioManager.play_dialog(next_text, speaker)
	label.text = next_text
	label.visible_ratio = 0.0
	change_state(State.READING)
	show_textbox(speaker)
	#Create tween
	current_tween = create_tween()
	current_tween.tween_property(label, "visible_ratio", 1.0, len(next_text) * CHAR_READ_RATE)
	current_tween.tween_callback(func():
		continue_hint.visible = true
		change_state(State.FINISHED))
		
func change_state(next_state):
	current_state = next_state
	

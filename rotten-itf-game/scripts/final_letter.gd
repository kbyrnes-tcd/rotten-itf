extends Control

var gaps = [
	{"before": "I am glad to be at peace here in my home. ", "after": "Something has taken root in my gardens, and they are exceptionally grand this winter.", "correct": "SOMETHING"},
	{"before": "Though I miss the sun, stars, and you,", "after": "my family here is flourishing.,", "correct": "IS"},
	{"before": "We are quite well and have been enjoying the good weather. My lilies are thriving,", "after": "and I plan to grow some more in my chambers, though they may be the wrong color for my decor.", "correct": "WRONG"},
	{"before": "I miss you dearly, and am excited to", "after": "bring about the blooms with you this spring.", "correct": "WITH"},
	{"before": "I am settling in comfortably this winter, and", "after": "have been enjoying the company of Hades.", "correct": "HADES"},
]

const CONSTELLATION_IMAGES = {
	"SOMETHING": preload("res://assets/images/minigames/constellation/Something.png"),
	"IS": preload("res://assets/images/minigames/constellation/Is.png"),
	"WRONG": preload("res://assets/images/minigames/constellation/Wrong.png"),
	"WITH": preload("res://assets/images/minigames/constellation/With.png"),
	"HADES": preload("res://assets/images/minigames/constellation/Hades.png"),
}

var current_gap_index = 0
var letter_read = false
var placed_symbols = {}
var symbols = ["SOMETHING", "IS", "WRONG", "WITH", "HADES"]

@onready var gap_before = $LetterSide/GapBefore
@onready var gap_after = $LetterSide/GapAfter
@onready var gap_image = $LetterSide/GapImage
@onready var feedback_label = $FeedbackLabel
@onready var continue_button = $ContinueButton
@onready var completed_letter = $"LetterSide/CompletedLetter"
@onready var instructions = $Instructions


signal minigame_complete

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	symbols.shuffle()
	
	var buttons = [
		$OptionsSide/Btn_0,
		$OptionsSide/Btn_1,
		$OptionsSide/Btn_2,
		$OptionsSide/Btn_3,
		$OptionsSide/Btn_4
	]
	
	for i in buttons.size():
		buttons[i].get_child(0).text = symbols[i]
		var captured = symbols[i]
		buttons[i].pressed.connect(func(): _on_symbol_selected(captured))
	
	continue_button.visible = false
	feedback_label.visible = false
	if not continue_button.pressed.is_connected(_on_continue_button_pressed):
		continue_button.pressed.connect(_on_continue_button_pressed)


	show_current_gap()

func show_current_gap():
	if current_gap_index >= gaps.size():
		all_gaps_filled()
		return
	var gap = gaps[current_gap_index]
	gap_before.text = gap["before"]
	gap_after.text = gap["after"]
	gap_image.texture = CONSTELLATION_IMAGES[gap["correct"]]
	feedback_label.visible = false

func _on_symbol_selected(symbol: String):
	var gap = gaps[current_gap_index]
	if symbol == gap["correct"]:
		correct_placement(symbol)
	else:
		wrong_placement(symbol)

func correct_placement(symbol: String):
	var tween = create_tween()
	tween.tween_property(gap_image, "modulate", Color(2,2,2), 0.2)
	tween.tween_property(gap_image, "modulate", Color.WHITE, 0.3)
	placed_symbols[current_gap_index] = symbol
	feedback_label.visible = false
	await get_tree().create_timer(0.6).timeout
	current_gap_index += 1
	show_current_gap()

func wrong_placement(_symbol: String):
	feedback_label.text = "Hmm... that doesn't feel right."
	feedback_label.visible = true
	await get_tree().create_timer(1.5).timeout
	feedback_label.visible = false

func all_gaps_filled():
	gap_before.visible = false
	gap_after.visible = false
	gap_image.visible = false
	$OptionsSide.visible = false
	instructions.visible = false
	completed_letter.text = build_complete_letter()
	completed_letter.visible = true
	feedback_label.text = "The letter is complete."
	feedback_label.visible = true
	continue_button.visible = true


func build_complete_letter() -> String:
	var full = "[color=#000000]"
	for i in gaps.size():
		var gap = gaps[i]
		var word = placed_symbols.get(i, "[" + gap["correct"] + "]")
		full += gap["before"] + " [font=res://assets/fonts/HyperlegibleSans-Bold.ttf][color=#FFFFF]" + word + " [/color][/font]" + gap["after"] + "\n\n"
	full += "[/color]"
	return full

func _on_continue_button_pressed():
		print("CONTUNYE PRESSED")
		var lio = get_tree().get_first_node_in_group("lio_manager")
		if lio:
			lio.show_sequence([
			"I understand now. Persephone was trying to warn her mother. This was a cry for help.",
			"My Goddess. I am starting to understand. I think I am ready to face your altar once more."], 4.0)
		GameGlobals.letter_minigame_complete = true
		emit_signal("minigame_complete")
		GameGlobals.unload_minigame()

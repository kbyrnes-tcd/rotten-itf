extends Node2D

var gaps = [
	{
		"before": "I am glad to be at peace here in my home. I am settling",
		"after": "in comfortably this winter, and have been enjoying the company of my husband.",
		"correct": "SOMETHING",
	},
	{
		"before": "We are quite well, and have been enjoying the good weather.",
		"after": "My lavender bush is thriving,",
		"correct": "IS",
	},
	{
		"before": ", and I plan to",
		"after": "grow some more in my chambers",
		"correct": "WRONG",
	},
	{
		"before": "Though I miss the sun, stars, and you",
		"after": ", my family here is flourishing.",
		"correct": "WITH",
	},
	{
		"before": "I miss you dearly, and am",
		"after": "glad to see you soon.",
		"correct": "HADES",
	},
]

var current_gap_index = 0
var letter_read = false
var placed_symbols = {}

@onready var gap_before = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapBefore
@onready var gap_after = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapAfter
@onready var gap_label = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapSlot/GapLabel
@onready var gap_slot = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapSlot
@onready var gap_row = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow
@onready var feedback_label = $FeedbackLabel
@onready var continue_button = $ContinueBtn
@onready var letter_body = $MainSplit/LetterPanel/LetterMargin/LetterContent/LetterBody
@onready var letter_content = $MainSplit/LetterPanel/LetterMargin/LetterContent
@onready var star_panel = $MainSplit/StarPanel
@onready var btn_something = $MainSplit/StarPanel/StarContent/Btn_some
@onready var btn_is = $MainSplit/StarPanel/StarContent/Btn_is
@onready var btn_wrong = $MainSplit/StarPanel/StarContent/Btn_wrong
@onready var btn_with = $MainSplit/StarPanel/StarContent/Btn_with
@onready var btn_hades = $MainSplit/StarPanel/StarContent/Btn_hades

signal minigame_complete

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.visible = false
	feedback_label.visible = false
	continue_button.pressed.connect(_on_continue_button_pressed)
	btn_something.pressed.connect(func(): _on_symbol_selected("SOMETHING"))
	btn_is.pressed.connect(func(): _on_symbol_selected("IS"))
	btn_wrong.pressed.connect(func(): _on_symbol_selected("WRONG"))
	btn_with.pressed.connect(func(): _on_symbol_selected("WITH"))
	btn_hades.pressed.connect(func(): _on_symbol_selected("HADES"))
	show_current_gap()

func show_current_gap():
	if current_gap_index >= gaps.size():
		all_gaps_filled()
		return
	var gap = gaps[current_gap_index]
	gap_slot.visible = true
	gap_before.text = gap["before"]
	gap_after.text = gap["after"]
	gap_label.text = " ? "
	feedback_label.visible = false

func _on_symbol_selected(symbol: String):
	var gap = gaps[current_gap_index]
	if symbol == gap["correct"]:
		correct_placement(symbol)
	else:
		wrong_placement(symbol)

func correct_placement(symbol: String):
	placed_symbols[current_gap_index] = symbol
	gap_label.text = symbol
	feedback_label.visible = false
	await get_tree().create_timer(0.6).timeout
	current_gap_index += 1
	show_current_gap()

func wrong_placement(_symbol: String):
	feedback_label.text = "Hmm... that doesn't feel right."
	feedback_label.visible = true
	var original_pos = gap_slot.position
	var tween = create_tween()
	tween.tween_property(gap_slot, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(gap_slot, "position", original_pos + Vector2(-8, 0), 0.05)
	tween.tween_property(gap_slot, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(gap_slot, "position", original_pos, 0.05)
	await get_tree().create_timer(1.5).timeout
	feedback_label.visible = false

func all_gaps_filled():
	gap_row.visible = false
	star_panel.visible = false
	var letter_label = Label.new()
	letter_label.text = build_complete_letter()
	letter_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	letter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	letter_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	letter_content.add_child(letter_label)
	letter_body.visible = false
	continue_button.visible = true
	feedback_label.text = "The letter is complete."
	feedback_label.visible = true

func build_complete_letter() -> String:
	var full = ""
	for i in gaps.size():
		var gap = gaps[i]
		var word = placed_symbols.get(i, "[" + gap["correct"] + "]")
		full += gap["before"] + " " + word + " " + gap["after"] + "\n\n"
	return full

func _on_continue_button_pressed():
	if not letter_read:
		letter_read = true
		continue_button.text = "POV shift"
		feedback_label.text = "She sealed the letter..."
		$MainSplit/LetterPanel.visible = false
	else:
		emit_signal("minigame_complete")
		GameGlobals.unload_minigame()

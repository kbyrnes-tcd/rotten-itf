extends Node2D

#Each gap is a line of Persephone letter --> text before and after the hidden word 
#and correct = constellation symbol word meaning
var gaps = [
	{
		"before" : "Dear Mother, I miss you",
		"after" : "this time of year.",
		"correct" : "PLAN",
	},
	{
		"before" : "The nymphs were",
		"after" : "and lonely this summer.",
		"correct" : "LOVE",
	},
	{
		"before" : "I",
		"after" : "it is my own doing. I hate it.",
		"correct" : "HELP",
	},
	{
		"before" : "Hades has been",
		"after" : "this time. Working so much",
		"correct" : "WINTER",
	},
	{
		"before" : "I",
		"after" : "something terrible is coming. I feel it.",
		"correct" : "FEAR",
	},
]

#Symbols options shown to player to choose from
var symbols = ["PLAN", "LOVE", "HELP", "WINTER", "FEAR"]

#state tracking
var current_gap_index = 0
var letter_read = false
var placed_symbols = {}
var current_tween = null

#node references
@onready var gap_before = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapBefore
@onready var gap_after = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapAfter
@onready var gap_label = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapSlot/GapLabel
@onready var symbol_grid = $MainSplit/StarPanel/StarMargin/StarContent/SymbolGrid
@onready var feedback_label = $FeedbackLabel
@onready var continue_button = $ContinueButton
@onready var letter_body = $MainSplit/LetterPanel/LetterMargin/LetterContent/LetterBody


#signals when player completed the minigame -- pressed continue
signal minigame_complete

func _ready():
	#to run even if game is paused
	process_mode = Node.PROCESS_MODE_ALWAYS
	#size everything for viewport
	var vp = get_viewport().get_visible_rect().size
	$Background.size = vp
	$Background.position = Vector2.ZERO
	
	$MainSplit.size = vp
	$MainSplit.position = Vector2.ZERO
	#feedbacklabel position
	feedback_label.position = Vector2(vp.x/2 - 150, vp.y - 80)
	feedback_label.size = Vector2(300,40)
	#continue button position
	continue_button.position = Vector2(vp.x/2 - 60, vp.y - 40)
	continue_button.size = Vector2(120, 30)
	
	#letter internal padding
	var letter_margin = $MainSplit/LetterPanel/LetterMargin
	letter_margin.add_theme_constant_override("margin_left", 20)
	letter_margin.add_theme_constant_override("margin_righ", 20)
	letter_margin.add_theme_constant_override("margin_top", 20)
	letter_margin.add_theme_constant_override("margin_bottom", 20)
	
	var gap_before_node = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapBefore
	var gap_after_node = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapAfter
	gap_before_node.custom_minimum_size = Vector2(120,0)
	gap_after_node.custom_minimum_size = Vector2(120,0)
	gap_before_node.autowrap_mode = TextServer.AUTOWRAP_WORD
	gap_after_node.autowrap_mode = TextServer.AUTOWRAP_WORD
	
	
	$MainSplit/LetterPanel.custom_minimum_size = Vector2(vp.x * 0.55, vp.y)
	$MainSplit/StarPanel.custom_minimum_size = Vector2(vp.x * 0.45, vp.y)
	continue_button.visible = false
	feedback_label.visible = false
	#initialize continue button
	continue_button.pressed.connect(_on_continue_button_pressed)
	build_symbol_buttons()
	#show first gap
	show_current_gap()

#creates one button per symbol on the right of screen
func build_symbol_buttons():
	for child in symbol_grid.get_children():
		child.queue_free()
	for symbol in symbols:
		var btn = Button.new()
		btn.text = symbol
		btn.custom_minimum_size = Vector2(120,80)
		var captured = symbol
		btn.pressed.connect(func(): _on_symbol_selected(captured))
		symbol_grid.add_child(btn)

#left side with respective gaps
func show_current_gap():
	if current_gap_index >= gaps.size():
		all_gaps_filled()
		return
	var gap = gaps[current_gap_index]
	$MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapSlot.visible = true
	gap_before.text = gap["before"]
	gap_after.text = gap["after"]
	gap_label.text = " ? "
	feedback_label.visible = false

#checks for correct matches when symbols are selected 
func _on_symbol_selected(symbol: String):
	print("selected: " + symbol)
	var gap = gaps[current_gap_index]
	if symbol == gap["correct"]:
		correct_placement(symbol)
	else:
		wrong_placement(symbol)
		
func correct_placement(symbol: String):
	placed_symbols[current_gap_index] = symbol
	gap_label.text = symbol
	print("placed: ", symbol, " gap_label text is now: ", gap_label.text)
	feedback_label.visible = false
	await get_tree().create_timer(0.6).timeout
	current_gap_index += 1
	show_current_gap()
	
func wrong_placement(_symbol: String):
	feedback_label.text = "Hmm...that doesn't feel right."
	feedback_label.visible = true
	
	var slot = $MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow/GapSlot
	var original_pos = slot.position
	var tween = create_tween()
	tween.tween_property(slot, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(slot, "position", original_pos + Vector2(-8, 0), 0.05)
	tween.tween_property(slot, "position", original_pos + Vector2(8, 0), 0.05)
	tween.tween_property(slot, "position", original_pos, 0.05)
	
	await get_tree().create_timer(1.5).timeout
	feedback_label.visible = false

#hides all the gaps and shows the completed final letter
func all_gaps_filled():
	$MainSplit/LetterPanel/LetterMargin/LetterContent/GapRow.visible = false
	$MainSplit/StarPanel.visible = false
	
	var letter_label = Label.new()
	letter_label.text = build_complete_letter()
	letter_label.autowrap_mode = TextServer.AUTOWRAP_WORD
	letter_label.custom_minimum_size = Vector2(300, 0)
	letter_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	letter_label.size_flags_vertical = Control.SIZE_EXPAND_FILL
	$MainSplit/LetterPanel/LetterMargin/LetterContent.add_child(letter_label)
	
	#hide the letter_body
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

#two presses to trigger next scene
func _on_continue_button_pressed():
	if not letter_read:
		letter_read = true
		continue_button.text = "POV shift"
		feedback_label.text = "She sealed the letter..bla bla"
		$MainSplit/LetterPanel.visible = false
	else: 
		emit_signal("minigame_complete")
		GameGlobals.unload_minigame()

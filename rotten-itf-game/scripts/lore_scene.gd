extends Node2D

const CHAR_READ_RATE = 0.04
@onready var lore_text = $CanvasLayer/LoreText
@onready var continue_hint = $CanvasLayer/ContinueHint


var lore_lines = [
	"There are gaps in my memory, the size and shape of my sisters in prayer.",
	"Sometimes when I close my eyes I see their faces, half eaten by decay even as they rush forward to protect me, but my memory of that night is hazy even now. ",
	"The Temple of Demeter was all I ever knew until that terrible day. That day when I finally snuck into Persephone’s hidden altar. ",
	"When I gave her my favorite possession, a dried out daffodil. When it melted away in my hand and erupted with the toxic scourge that spread through the halls like a plague.",
	"I don’t know why the Rot spared me. Nor do I know why it continues to spare my skin even now.",
	"Maybe my offering to Persephone’s was too blessed. ",
	"Maybe it was too terrible. ",
	"All I know is that the Rot has found its way out of that temple, and I need to return to the place I once called home and find a way to stop this scourge upon the earth. ",
	"Alone. "
]

enum State { READY, READING, FINISHED }
var current_state = State.READY
var current_line = 0
var current_tween = null

func _ready():
	continue_hint.visible = false
	lore_text.text = ""
	lore_text.visible_ratio = 0.0

func _process(_delta):
	match current_state:
		State.READY:
			display_next_line()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				# skip typewriter
				lore_text.visible_ratio = 1.0
				if current_tween:
					current_tween.kill()
				continue_hint.visible = true
				change_state(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				current_line += 1
				if current_line >= lore_lines.size():
					# all lines done — go to next scene
					GameGlobals.load_level("scene_01")
				else:
					change_state(State.READY)

func display_next_line():
	if current_line >= lore_lines.size():
		GameGlobals.load_level("scene_01")
		return
	var line = lore_lines[current_line]
	lore_text.text = line
	lore_text.visible_ratio = 0.0
	continue_hint.visible = false
	change_state(State.READING)
	current_tween = create_tween()
	current_tween.tween_property(lore_text, "visible_ratio", 1.0, len(line) * CHAR_READ_RATE)
	current_tween.tween_callback(func():
		continue_hint.visible = true
		change_state(State.FINISHED))

func change_state(next_state):
	current_state = next_state

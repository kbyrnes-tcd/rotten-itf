#credits: https://store.godotengine.org/asset/fletchi/basiccreditstemplate/
extends Control

@export var scroll_speed: float = 50.0
@export var main_menu_scene: String = "res://scenes/levels/intro.tscn"
@export var TitleFont : Font
@export var LegibleFont : Font

@onready var credits_container = $CreditsContainer

var credits_data = [
	{"title": "THANK YOU FOR PLAYING", "roles": "", "name": ""},
	{"title": "-----", "roles": "", "name": ""},
	{"title": "OUR PANTHEON..", "roles": "", "name": ""},
	{"title": "", "name": "Annika McTamaney", "roles": ["Asset Generator", "Dialogue Designer", "Narrative Designer", "Project Manager"]},
	{"title": "", "name": "Kayla Byrnes", "roles": ["Asset Generator" , "Art Director" , "Game Designer", "Level Designer", "UI/UX Designer"]},
	{"title": "", "name": "Logan Dulski", "roles": ["Art Director", "Game Designer", "Graphic Designer", "Level Designer", "Sound Designer"]},
	#{"title": "", "name": "Minoli Mathew", "roles": ["Game Developer", "Game Designer", "Level Designer", "Programmer", "Captain Motherfucker"]},
	#{"title": "", "name": "Sengul Cagdal", "roles": ["Game Developer", "Game Designer", "Level Designer", "Programmer", "Chief Motherfucker"]}
	{"title": "", "name": "Minoli Mathew", "roles": ["Game Developer", "Game Designer", "Level Designer", "Programmer"]},
	{"title": "", "name": "Sengul Cagdal", "roles": ["Game Developer", "Game Designer", "Level Designer", "Programmer"]}
]

func _ready() -> void:
	print("inst credits")
	for entry in credits_data:
		print("in for loop")
		if entry["title"] != "":
			var title_label = Label.new()
			title_label.text = entry["title"]
			title_label.add_theme_font_override("font", TitleFont)
			title_label.add_theme_font_size_override("font_size", 40)
			title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			title_label.add_theme_color_override("font_color", Color(0.749, 0.525, 0.247, 1.0))
			print("got title %s adding to child %s" %[title_label.text, credits_container.get_path()])
			credits_container.add_child(title_label)
			print(title_label.get_path())
	
		if entry["name"] != "":
			var name_label = Label.new()
			name_label.text = entry["name"]
			name_label.add_theme_font_override("font", TitleFont)
			name_label.add_theme_font_size_override("font_size", 40)
			name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			#name_label.add_theme_color_override("font_color", Color(0.749, 0.525, 0.247, 1.0))
			name_label.add_theme_color_override("font_color", Color(0.851, 0.137, 0.267, 1.0))
			credits_container.add_child(name_label)
		
		var roles = entry["roles"]
		for role in roles:
			var role_label = Label.new()
			role_label.text = role
			role_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			role_label.add_theme_font_size_override("font_size", 15)
			credits_container.add_child(role_label)
		
		var spacer = Control.new()
		spacer.custom_minimum_size.y = 20
		credits_container.add_child(spacer)
	
	credits_container.position.y = get_viewport_rect().size.y

func _process(delta: float) -> void:
	#await get_tree().create_timer(1.0).timeout
	credits_container.position.y -= scroll_speed * delta

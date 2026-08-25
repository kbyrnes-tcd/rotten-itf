extends CanvasLayer
@onready var rot_animation_player: AnimationPlayer = $RotCutscene/AnimationPlayer
@onready var rot_cutscene: CanvasLayer = $RotCutscene
@onready var color_rect: ColorRect = $RotCutscene/ColorRect
@onready var vines: Node2D = $RotCutscene/Vines

func play_rot_cutscene():
	rot_cutscene.visible = true
	rot_animation_player.play("RESET")
	await rot_animation_player.animation_finished
	return

func fade_out():
	print("fading out")
	var out_tween = create_tween()
	vines.visible = false # disable vines so they dont show while fading out color_rect
	await out_tween.tween_property(color_rect, "modulate:a", 0.0, 0.5).finished
	rot_cutscene.visible = false

extends CanvasLayer
@onready var rot_animation_player: AnimationPlayer = $RotCutscene/AnimationPlayer
@onready var rot_cutscene: CanvasLayer = $RotCutscene

func play_rot_cutscene():
	rot_cutscene.visible = true
	rot_animation_player.play("RESET")
	await rot_animation_player.animation_finished
	print("anim fin!")

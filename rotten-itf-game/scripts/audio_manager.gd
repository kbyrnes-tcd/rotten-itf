extends Node

var active_ambience : AudioStreamPlayer
var active_os : AudioStreamPlayer # one shot sfx
var active_fx : AudioStreamPlayer # looping fx that only one of can play at a time e.g. grow/shrink
var active_walk_fx : AudioStreamPlayer # walking fx should be able to be layered

@export var clips: Node
@export_group("Source")
@export var fx: Dictionary[String, AudioStream] = {
}
@export_group("Arrays")
@export var win_fx: Array[AudioStream] = []
@export var scraps_fx: Array[AudioStream] = []
@export var alphabet_fx : Array[AudioStream] = []

func _ready() -> void:
	active_os = clips.get_node("OneShotFX")
	active_walk_fx = clips.get_node("WalkFX")

# need 2 rework like w/ play_os to play dynamic ambience
func play_ambience(am_name: String, from: float = 0.0, skip_restart: bool = false) -> void:
	if skip_restart and active_ambience and active_ambience.name == am_name:
		return
	active_ambience = clips.get_node(am_name)
	active_ambience.play(from)
	
func play_fx(fx_name: String, from: float = 0.0) -> void:
	if !active_fx:
		#print("playing fx %s" %fx_name)
		active_fx = clips.get_node("LoopFX")
		active_fx.stream = fx[fx_name]
		active_fx.play(from)
	
func stop_fx() -> void:
	if active_fx:
		#print("stopping fx")
		active_fx.stop()
		active_fx = null

func play_walk_fx() -> void:
	if !active_walk_fx:
		active_walk_fx.stream = fx["walk"]
		active_walk_fx.play()

func stop_walk_fx() -> void:
	if active_walk_fx:
		active_walk_fx.stop()
		active_walk_fx = null

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("down"):
		AudioManager.play_dialog("Hiii !!! i'm tired")

func play_dialog(copy: String, base_pitch: float = 1.75, pitch_variance: float = .5) -> void:
	copy = copy.to_lower()
	for c in copy:
		var index := ord(c)-97
		if index < 0 or index > 25:
			var pause := 0.1 if c == " " else 0.2
			await get_tree().create_timer(pause).timeout
			continue
		active_os.stream = alphabet_fx[index]
		# pitch and variance
		active_os.pitch_scale = base_pitch + randf_range(-pitch_variance, pitch_variance)
		active_os.play()
		await active_os.finished

func play_os_from_arr(arr_name: String, index : int = -1, from: float = 0.0) -> void:
	var os_arr = get(arr_name + "_fx")
	active_os.stream = os_arr[index] if index != -1 else os_arr.pick_random()
	#print("playing os %s" %index)
	active_os.play(from)
	return
	
# one shot - only played once no loop
func play_os(os_name: String, from: float = 0.0) -> void:
	active_os.stream = fx[os_name]
	active_os.play(from)

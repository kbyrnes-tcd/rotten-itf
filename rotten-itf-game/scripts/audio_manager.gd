extends Node

# audiostreamplayers
var active_ambience : AudioStreamPlayer
var active_music : AudioStreamPlayer
var active_fx : AudioStreamPlayer # looping fx that only one of can play at a time e.g. grow/shrink
var active_walk_fx : AudioStreamPlayer # walking fx should be able to be layered
@onready var active_os: AudioStreamPlayer = $Clips/OneShotFX
@onready var dialog_os: AudioStreamPlayer = $Clips/DialogOneShotFX

# fade in/out tweens
var walk_tween : Tween
var fx_tween : Tween
var am_tween : Tween
var music_tween : Tween

# source fx/music files
@export var clips: Node
@export_group("Source")
@export var fx: Dictionary[String, AudioStream] = {}
@export var ambi_vol : float = 0.0
@export var music_vol : float = -8.0
@export_group("Music")
@export var ambiences : Dictionary[String, AudioStream] = {}
@export var music : Dictionary[String, AudioStream] = {}
@export_group("FX_Arrays")
@export var win_fx: Array[AudioStream] = []
@export var scraps_fx: Array[AudioStream] = []
@export var daphne_alpha : Array[AudioStream] = []
@export var persephone_alpha : Array[AudioStream] = []
@export var highpriestess_alpha : Array[AudioStream] = []

func get_cur_song():
	return "%s & %s" %[active_music.stream.resource_path.get_file().get_basename(), active_music.volume_db] if active_music!=null else "n/a"

func get_cur_ambience():
	return "%s & %s" %[active_ambience.stream.resource_path.get_file().get_basename(), active_ambience.volume_db] if active_ambience!=null else "n/a"

func fade(c_tween:Tween, stream:AudioStreamPlayer, start_vol := 0.0, end_vol := 0.0, dur := 0.5, stop_on_end := false):
	if c_tween:
		c_tween.kill()
	c_tween = create_tween()
	stream.volume_db = start_vol
	c_tween.tween_property(stream, "volume_db", end_vol, dur)
	await c_tween.finished
	c_tween.stop()
	
	# if fading out
	if end_vol < start_vol and stop_on_end:
		stream.stop()
		#print("fading out: %s" % stream.stream.resource_path.get_file().get_basename())
	#else:
		#print("Fading in")
	return c_tween

func change_ambience(am_name: String) -> void:
	if active_ambience:
		var c_am := active_ambience.stream.resource_path.get_file().get_basename()
		# if it's the same track, keep continue
		if c_am == am_name: return
		else: 
			#print("not the same am so changing TO %s from %s" %[am_name, c_am])
			am_tween = await fade(am_tween, active_ambience, ambi_vol, ambi_vol-20, 1.0, true) # fadeOUT current track b4 changing
			active_ambience = null
			play_ambience(am_name)

func play_ambience(am_name: String) -> void:
	if !active_ambience:
		active_ambience = clips.get_node("Ambience")
		active_ambience.stream = ambiences[am_name]
		#print("fading in %s" %am_name)
		am_tween = await fade(am_tween, active_ambience, ambi_vol-20, ambi_vol, 1.0) # fadeIN new track
		#print("calling play")
		active_ambience.play()

func change_music(song: String) -> void:
	if active_music:
		var c_song := active_music.stream.resource_path.get_file().get_basename()
		# if it's the same track, keep continue
		print(c_song.get_basename())
		if c_song == song: return
		else: 
			if song.get_basename() == "Title_Song": music_vol = 5.0
			else: music_vol = -8.0
			music_tween = await fade(music_tween, active_music, music_vol, music_vol-20, 1.0, true) # fadeOUT current track b4 changing
			active_music = null
			play_music(song)

func play_music(song: String) -> void:
	if !active_music:
		active_music = clips.get_node("Music")
		active_music.stream = music[song]
		if song.get_basename() == "Title_Song": music_vol = 5.0
		else: music_vol = -8.0
		music_tween = await fade(music_tween, active_music, music_vol-20, music_vol, 1.0) # fadeIN new track
		active_music.play()

func increase_music_vol(amount: float = 15.0, dur: float = 1.5):
	if music_tween:
		music_tween = await fade(music_tween, active_music, active_music.volume_db, active_music.volume_db + amount, dur)
	else: 
		music_tween = create_tween()

func decrease_music_vol(amount: float = 15.0, dur: float = 1.5):
	if music_tween:
		music_tween = await fade(music_tween, active_music, active_music.volume_db, active_music.volume_db - amount, dur)
	else: 
		music_tween = create_tween()

func play_walk_fx() -> void:
	if !active_walk_fx:
		active_walk_fx = clips.get_node("WalkFX")
		active_walk_fx.stream = fx["walk"]
		var fx_ref = active_walk_fx 
		walk_tween = await fade(walk_tween, active_walk_fx, -10.0, 0.0, 0.2)
		if fx_ref:
			fx_ref.play()

func stop_walk_fx() -> void:
	if active_walk_fx:
		walk_tween = await fade(walk_tween, active_walk_fx, 0.0, -10.0, 0.2)
		active_walk_fx = null

func play_fx(fx_name: String, from: float = 0.0) -> void:
	if !active_fx:
		active_fx = clips.get_node("LoopFX")
		active_fx.stream = fx[fx_name]
		fx_tween = await fade(fx_tween, active_fx, -50.0, -15.0, 0.1)
		active_fx.play(from)
	
func stop_fx() -> void:
	if active_fx:
		fx_tween = await fade(fx_tween, active_fx, -15.0, -50.0, 0.1)
		active_fx = null

var skip := false
var dialog_id := 0

func skip_dialog():
	if dialog_os:
		dialog_os.stop()
	dialog_os = null
	skip = true

func play_dialog(copy: String, speaker: String = "", letter_speed: float = 0.15, base_pitch: float = 1.0, pitch_variance: float = 0.15) -> void:
	stop_walk_fx()
	dialog_id += 1 # incr per dialog line
	#copy = copy.to_lower().substr(0, 30)
	skip = false
	dialog_os = null
	var cur_id := dialog_id
	
	for c in copy:
		if skip or cur_id != dialog_id: return # if new line, skip
		var index := ord(c)-97
		if index < 0 or index > 25:
			await get_tree().create_timer(letter_speed * 1.05).timeout
			#index = 26
			continue
		else: index = randi_range(0, index)
		if skip: return

		if !dialog_os: dialog_os = clips.get_node("OneShotFX")
		var speaker_alphabet = get(speaker.to_lower() + "_alpha")
		dialog_os.volume_db = -20.0
		dialog_os.stream = speaker_alphabet[index]
		# pitch and variance
		dialog_os.pitch_scale = base_pitch + randf_range(-pitch_variance, pitch_variance)
		dialog_os.play()
		#await get_tree().create_timer(letter_speed).timeout
		#await dialog_os.finished
		dialog_os = null
	
	# return dialog_os to original state
	dialog_os = clips.get_node("OneShotFX")
	dialog_os.volume_db = -20.0

func play_os_from_arr(arr_name: String, index : int = -1, from: float = 0.0) -> void:
	var os_arr = get(arr_name + "_fx")
	active_os.stream = os_arr[index] if index != -1 else os_arr.pick_random()
	active_os.play(from)
	return
	
# one shot - only played once no loop
func play_os(os_name: String, from: float = 0.0) -> void:
	if !active_os:
		active_os = clips.get_node("OneShotFX")
	if !fx.has(os_name):
		print("fx key not found: " + os_name)
		return
	active_os.stream = fx[os_name]
	active_os.play(from)

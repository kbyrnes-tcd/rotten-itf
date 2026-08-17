extends Node

# audiostreamplayers
var active_ambience : AudioStreamPlayer
var active_music : AudioStreamPlayer
var active_fx : AudioStreamPlayer # looping fx that only one of can play at a time e.g. grow/shrink
var active_walk_fx : AudioStreamPlayer # walking fx should be able to be layered
@onready var active_os: AudioStreamPlayer = $Clips/OneShotFX

# fade in/out tweens
var walk_tween : Tween
var fx_tween : Tween
var am_tween : Tween
var music_tween : Tween

# source fx/music files
@export var clips: Node
@export_group("Source")
@export var fx: Dictionary[String, AudioStream] = {}
@export_group("Music")
@export var ambiences : Dictionary[String, AudioStream] = {}
@export var music : Dictionary[String, AudioStream] = {}
@export_group("FX_Arrays")
@export var win_fx: Array[AudioStream] = []
@export var scraps_fx: Array[AudioStream] = []
@export var alphabet_fx : Array[AudioStream] = []

func get_cur_song():
	return "%s & %s" %[active_music.stream.resource_path.get_file().get_basename(), active_music.volume_db] if active_music!=null else "n/a"

func get_cur_ambience():
	return "%s & %s" %[active_ambience.stream.resource_path.get_file().get_basename(), active_ambience.volume_db] if active_ambience!=null else "n/a"

func fade(c_tween:Tween, stream:AudioStreamPlayer, start_vol := 0.0, end_vol := 0.0, dur := 0.5):
	if c_tween:
		c_tween.kill()
	c_tween = create_tween()
	stream.volume_db = start_vol
	c_tween.tween_property(stream, "volume_db", end_vol, dur)
	await c_tween.finished
	c_tween.stop()
	
	# if fading out
	if end_vol < start_vol:
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
			am_tween = await fade(am_tween, active_ambience, -10.0, -30.0, 1.0) # _tween = await fadeout current track b4 changing
			active_ambience = null
			play_ambience(am_name)

func play_ambience(am_name: String) -> void:
	if !active_ambience:
		active_ambience = clips.get_node("Ambience")
		active_ambience.stream = ambiences[am_name]
		#print("fading in %s" %am_name)
		am_tween = await fade(am_tween, active_ambience, -25.0, -10.0, 1.0)
		#print("calling play")
		active_ambience.play()

func change_music(song: String) -> void:
	if active_music:
		var c_song := active_music.stream.resource_path.get_file().get_basename()
		# if it's the same track, keep continue
		if c_song == song: return
		else: 
			music_tween = await fade(music_tween, active_music, -30.0, -50.0, 1.0) # fade current track b4 changing
			active_music = null
			play_music(song)

func play_music(song: String) -> void:
	if !active_music:
		active_music = clips.get_node("Music")
		active_music.stream = music[song]
		music_tween = await fade(music_tween, active_music, -50.0, -30, 1.0)
		active_music.play()

func increase_music_vol(amount: float = 15.0, dur: float = 1.5):
	music_tween = await fade(music_tween, active_music, active_music.volume_db, active_music.volume_db + amount, dur)

func decrease_music_vol(amount: float = 15.0, dur: float = 1.5):
	music_tween = await fade(music_tween, active_music, active_music.volume_db, active_music.volume_db - amount, dur)

func play_walk_fx() -> void:
	if !active_walk_fx:
		active_walk_fx = clips.get_node("WalkFX")
		active_walk_fx.stream = fx["walk"]
		walk_tween = await fade(walk_tween, active_walk_fx, -10.0, 0.0, 0.2)
		active_walk_fx.play()

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

#func _process(_delta: float) -> void:
	#if Input.is_action_just_pressed("down"):
		#AudioManager.play_dialog("I lasted as long as I could in this ruined Temple, but even my Patron Demeter could only protect me for so long.")
	#if Input.is_action_just_pressed("up"):
		#AudioManager.play_dialog("Hi")
		
func play_dialog(copy: String, speaker: String = "", letter_speed: float = 0.15, base_pitch: float = 1.5, pitch_variance: float = 0.25) -> void:
	copy = copy.to_lower().substr(0, 20)
	for c in copy:
		var index := ord(c)-97
		if index < 0 or index > 25:
			await get_tree().create_timer(letter_speed * 1.05).timeout
			continue
		index = randi_range(0, index)
		
		if speaker != "Daphne": base_pitch = 1.25

		#var dialog_audio := AudioStreamPlayer.new()
		#get_tree().root.add_child(dialog_audio)
		if !active_os: active_os = clips.get_node("OneShotFX")
		active_os.volume_db = -20.0
		active_os.stream = alphabet_fx[index]
		# pitch and variance
		active_os.pitch_scale = base_pitch + randf_range(-pitch_variance, pitch_variance)
		active_os.play()
		await get_tree().create_timer(letter_speed).timeout
		active_os = null
	
	# return active_os to original state
	active_os = clips.get_node("OneShotFX")
	active_os.volume_db = -20.0

func play_os_from_arr(arr_name: String, index : int = -1, from: float = 0.0) -> void:
	var os_arr = get(arr_name + "_fx")
	active_os.stream = os_arr[index] if index != -1 else os_arr.pick_random()
	active_os.play(from)
	return
	
# one shot - only played once no loop
func play_os(os_name: String, from: float = 0.0) -> void:
	active_os.stream = fx[os_name]
	active_os.play(from)

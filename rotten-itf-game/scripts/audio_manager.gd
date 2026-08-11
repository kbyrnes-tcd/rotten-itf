extends Node

var active_ambience : AudioStreamPlayer
var active_os : AudioStreamPlayer # one shot sfx
var active_fx : AudioStreamPlayer # looping fx that only one of can play at a time e.g. grow/shrink
var active_walk_fx : AudioStreamPlayer # walking fx should be able to be layered

@export var clips: Node
@export_group("Source")
@export var fx: Dictionary[String, AudioStream] = {
	"walk": null,
	"open_door": null,
	"equip": null,
	"place": null,
	"grow": null,
	"shrink": null,
	"torch": null
}

# need 2 rework like w/ play_os to play dynamic ambience
func play_ambience(name: String, from: float = 0.0, skip_restart: bool = false) -> void:
	if skip_restart and active_ambience and active_ambience.name == name:
		return
	active_ambience = clips.get_node(name)
	active_ambience.play(from)
	
func play_fx(name: String, from: float = 0.0) -> void:
	if !active_fx:
		print("playing fx %s" %name)
		active_fx = clips.get_node("LoopFX")
		active_fx.stream = fx[name]
		active_fx.play(from)
		print(active_fx)
	
func stop_fx() -> void:
	if active_fx:
		print("stopping fx")
		active_fx.stop()
		active_fx = null

func play_walk_fx() -> void:
	if !active_walk_fx:
		active_walk_fx = clips.get_node("WalkFX")
		active_walk_fx.stream = fx["walk"]
		active_walk_fx.play()

func stop_walk_fx() -> void:
	if active_walk_fx:
		active_walk_fx.stop()
		active_walk_fx = null

# one shot - only played once no loop
func play_os(name: String, from: float = 0.0) -> void:
	active_os = clips.get_node("OneShotFX")
	active_os.stream = fx[name]
	active_os.play(from)

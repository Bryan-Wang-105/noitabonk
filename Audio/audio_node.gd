extends Node

@onready var gold_audio: AudioStreamPlayer = $GoldAudio
@onready var xp_audio: AudioStreamPlayer = $XPAudio
@onready var level_up_audio: AudioStreamPlayer = $LevelUpAudio

var sound_fx = {
	"gold_pickup" : "uid://d3g8ku4ywrc1t",
	"xp_pickup" : "uid://c834tu2bowq1g",
	"level_up" : "uid://b37m0wxkatbjl",
	
}

func _ready():
	Global.audio_node = self
	
	gold_audio.stream = load(sound_fx["gold_pickup"])
	xp_audio.stream = load(sound_fx["xp_pickup"])
	level_up_audio.stream = load(sound_fx["level_up"])

func play_gold_pickup_fx():
	gold_audio.play()

func play_xp_pickup_fx():
	xp_audio.play()

func play_lvl_up_fx():
	level_up_audio.play()

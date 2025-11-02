extends Node

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var sound_fx = {
	"gold_pickup" : "uid://d3g8ku4ywrc1t"
}

func _ready():
	Global.audio_node = self
	

func play_gold_pickup_fx():
	audio_stream_player.stream = load(sound_fx["gold_pickup"])
	audio_stream_player.play()

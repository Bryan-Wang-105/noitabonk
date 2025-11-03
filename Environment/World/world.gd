extends Node3D

@onready var enemy_manager: Node = $EnemyManager
@onready var player: CharacterBody3D = $Player
@onready var sandbox: Node3D = $Sandbox

var elapsed_time: float = 0.0
var started = false

func _ready() -> void:
	Global.world = self
	Global.player = player
	
	enemy_manager.spawn_enemies()
	started = true


func _process(delta):
	if started:
		elapsed_time += delta

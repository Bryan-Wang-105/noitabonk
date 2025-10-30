extends Node3D

@onready var enemy_manager: Node = $EnemyManager
@onready var player: CharacterBody3D = $Player
@onready var sandbox: Node3D = $Sandbox

func _ready() -> void:
	Global.world = self
	Global.player = player
	
	enemy_manager.spawn_enemies()

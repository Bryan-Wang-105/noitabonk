extends Control

@onready var lvl_num: Label = $PanelContainer/Control/LvlNum

var is_leveling_up = false

func _ready():
	visible = false
	
	Global.playerManager.connect("level_changed", open_lvlup_menu)
	
	# This menu should work when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func open_lvlup_menu(level):
	lvl_num.text = str(level)
	
	# Pause the game
	is_leveling_up = true
	get_tree().paused = !get_tree().paused
	
	visible = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	return

func close_lvlup_menu():
	visible = false
	# Pause the game
	is_leveling_up = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = !get_tree().paused
	return


func choose_reward(slot: int) -> void:
	print("Choose reward " + str(slot + 1))
	
	close_lvlup_menu()

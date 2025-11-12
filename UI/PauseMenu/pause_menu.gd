# pause_menu.gd
extends Control

@onready var resume_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/ResumeBtn
@onready var exit_btn: Button = $PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/ExitBtn


func _ready():
	print("AAA")
	# This menu should work when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	
	# Connect buttons
	resume_btn.pressed.connect(_on_resume_pressed)
	exit_btn.pressed.connect(_on_quit_pressed)
	
	# Start hidden
	hide()


func toggle_pause():
	var is_paused = get_tree().paused
	var is_leveling = Global.canvas_layer.level_up_ui.is_leveling_up
	
	# Case 1: Currently leveling up
	if is_leveling:
		# Don't allow manual pause/unpause during level up
		# Just toggle pause menu visibility for viewing options
		visible = !visible
		if visible:
			resume_btn.grab_focus()
		# Mouse stays visible, game stays paused
		return
	
	# Case 2: Normal pause toggle (not leveling up)
	get_tree().paused = !is_paused
	Global.paused = !is_paused
	visible = !is_paused
	
	# Handle mouse mode
	if get_tree().paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		resume_btn.grab_focus()
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_resume_pressed():
	toggle_pause()

func _on_settings_pressed():
	# Open settings menu
	pass

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()
	#get_tree().change_scene_to_file("res://main_menu.tscn")

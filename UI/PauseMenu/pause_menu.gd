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
	
	if !is_paused:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	else:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	get_tree().paused = !is_paused
	visible = !is_paused
	
	# Grab focus when opening menu
	if visible:
		resume_btn.grab_focus()

func _on_resume_pressed():
	toggle_pause()

func _on_settings_pressed():
	# Open settings menu
	pass

func _on_quit_pressed():
	get_tree().paused = false
	get_tree().quit()
	#get_tree().change_scene_to_file("res://main_menu.tscn")

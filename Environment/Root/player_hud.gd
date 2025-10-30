extends Control


@onready var fps: Label = $FPS
@onready var crosshair: Label = $crosshair
@onready var prompt_label: Label = $PromptLabel
@onready var cast: Label = $Cast
@onready var reload: Label = $Reload

@onready var wand_1: Label = $HBoxContainer/Wand1
@onready var wand_2: Label = $HBoxContainer/Wand2
@onready var wand_3: Label = $HBoxContainer/Wand3
@onready var wand_4: Label = $HBoxContainer/Wand4

var wand_controller
var wand_inventory

var wand_labels 

func _ready() -> void:
	wand_controller = Global.wandController
	wand_inventory = Global.wandInventory

	wand_inventory.connect("inventory_changed", update_active_wand_bar)
	
	wand_labels = [wand_1, wand_2, wand_3, wand_4]

func _process(delta: float) -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	cast.text = "Cast Delay: %.2f" % (wand_controller.cast_delay_timer)
	reload.text = "Reload Time: %.2f" % (wand_controller.reload_timer)

func update_active_wand_bar():
	for i in range(wand_inventory.MAX_WANDS):
		if wand_inventory.wands[i]:
			wand_labels[i].text = "Wand " + str(i + 1)
		if wand_inventory.active_slot == i:
			wand_labels[i].text = "ACTIVE\nWand " + str(i + 1)
	
	print("Updated active wand bar")

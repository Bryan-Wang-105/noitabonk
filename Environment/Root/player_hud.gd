extends Control


@onready var fps: Label = $FPS
@onready var crosshair: Label = $crosshair
@onready var prompt_label: Label = $PromptLabel
@onready var cast: Label = $Cast
@onready var reload: Label = $Reload

@onready var wand_1: Label = $WandsBar/MarginContainer/HBoxContainer/PanelContainer/MarginContainer/Label#$HBoxContainer/Wand1
@onready var wand_2: Label = $WandsBar/MarginContainer/HBoxContainer/PanelContainer2/MarginContainer/Label#$HBoxContainer/Wand2
@onready var wand_3: Label = $WandsBar/MarginContainer/HBoxContainer/PanelContainer3/MarginContainer/Label#$HBoxContainer/Wand3
@onready var wand_4: Label = $WandsBar/MarginContainer/HBoxContainer/PanelContainer4/MarginContainer/Label#$HBoxContainer/Wand4

@onready var hp_bar: ProgressBar = $Health/ProgressBar
@onready var hp_lbl: Label = $Health/Label


@onready var xp_bar: ProgressBar = $Exp/ProgressBar
@onready var xp_lbl: Label = $Exp/Label

@onready var gold_lbl: Label = $PanelContainer/Control/Label
@onready var gold_added: Label = $PanelContainer/Control/GoldAdded

var wand_controller
var wand_inventory

var wand_labels 

func _ready() -> void:
	wand_controller = Global.wandController
	wand_inventory = Global.wandInventory
	
	update_health()
	update_xp()
	update_gold()
	
	Global.playerManager.connect("health_changed", update_health)
	Global.playerManager.connect("experience_changed", update_xp)
	Global.playerManager.connect("gold_changed", update_gold)
	
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

func update_health():
	hp_bar.value = 100 * Global.playerManager.health / Global.playerManager.max_health 
	hp_lbl.text = str(Global.playerManager.health) + " / " + str(Global.playerManager.max_health) + " HP"

func update_xp():
	xp_bar.value = Global.playerManager.experience / Global.playerManager.max_experience
	xp_lbl.text = str(Global.playerManager.experience) + " / " + str(Global.playerManager.max_experience) + " XP"


func update_gold(amount = 0):
	
	if amount:
		# Show the +amount label
		gold_added.show_gold_added(amount)
	
	gold_lbl.text = "$ " + str(Global.playerManager.gold)
	

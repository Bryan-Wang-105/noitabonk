extends HBoxContainer

@onready var level: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Level
@onready var enhanced_xp: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/EnhancedXP

@onready var max_hp: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/MaxHP
@onready var hp_regen: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/HP_Regen
@onready var enhanced_hp: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/EnhancedHP

@onready var walk_speed: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/WalkSpeed
@onready var sprint_speed: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/SprintSpeed
@onready var jump_height: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/JumpHeight

@onready var crit_chance: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/CritChance
@onready var crit_dmg: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/CritDmg

@onready var life_steal: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/LifeSteal

@onready var gold_gain: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Gold_Gain
@onready var gold_gain_2: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Pickup_Radius
@onready var luck: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Luck2

func _ready():
	pass

func _update_stats():
	level.text = str(Global.playerManager.curr_level)
	
	max_hp.text = str(Global.playerManager.max_health)
	
	
	walk_speed.text = str(Global.playerManager.walk_speed)
	sprint_speed.text = str(Global.playerManager.sprint_speed)

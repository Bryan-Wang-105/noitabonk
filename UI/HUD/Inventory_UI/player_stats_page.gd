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
@onready var pickup_radius: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Pickup_Radius
@onready var luck: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2/Luck2

func _ready():
	Global.playerManager.connect("stats_changed", _update_stats)
	pass

func _update_stats():
	var pm = Global.playerManager
	
	# Level
	level.text = str(pm.curr_level)
	
	# XP Stats
	enhanced_xp.text = "%.0f%%" % (pm.enhanced_xp_gain * 100)
	
	# Health Stats
	max_hp.text = "%.0f" % pm.max_health
	hp_regen.text = "%.0f" % (pm.hp_regen * 100)
	enhanced_hp.text = "%.0f%%" % (pm.enhanced_hp_gain * 100)
	
	# Movement Stats
	walk_speed.text = "%.1f" % pm.walk_speed
	sprint_speed.text = "%.1f" % pm.sprint_speed
	jump_height.text = "%.1f" % pm.jump_height
	
	# Crit Stats (assuming critical_strike_chance is 0.0-1.0, convert to %)
	crit_chance.text = "%.0f%%" % (pm.critical_strike_chance * 100)
	crit_dmg.text = "%.0f%%" % pm.critical_strike_dmg
	
	# Misc Stats
	life_steal.text = "%.0f%%" % (pm.life_steal * 100)
	gold_gain.text = "%.0f%%" % (pm.enhanced_gold_gain * 100)
	pickup_radius.text = "%.0fm" % (pm.pickup_range * 100)
	luck.text = "%.0f" % (pm.luck * 100)

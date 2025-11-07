extends Control

@onready var lvl_num: Label = $PanelContainer/Control/LvlNum

@onready var rewards_vbox: VBoxContainer = $PanelContainer/Control/PanelContainer2/MarginContainer/VBoxContainer/RewardsVbox

@onready var enhanced_xp: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/EnhancedXP
@onready var max_hp: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/MaxHP
@onready var hp_regen: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/HP_Regen
@onready var enhanced_hp: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/EnhancedHP
@onready var walk_speed: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/WalkSpeed
@onready var sprint_speed: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/SprintSpeed
@onready var jump_height: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/JumpHeight
@onready var crit_chance: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/CritChance
@onready var crit_dmg: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/CritDmg
@onready var life_steal: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/LifeSteal
@onready var gold_gain: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/Gold_Gain
@onready var pickup_range: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/Pickup_Range
@onready var luck: Label = $PanelContainer/Control/PanelContainer/MarginContainer/HBoxContainer/CurrentStatsLbl/Luck2

var rewards
var reward_slot = load("uid://d3cj3p5eet27k")
var reward_slots = []

var is_leveling_up = false

func _ready():
	visible = false
	
	Global.playerManager.connect("level_changed", open_lvlup_menu)
	fill_labels()
	
	
	# This menu should work when game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

func fill_labels():
	var pm = Global.playerManager
	
	# XP Stats
	enhanced_xp.text = "%.1f%%" % pm.enhanced_xp_gain
	
	# Health Stats
	max_hp.text = "%.0f" % pm.max_health
	hp_regen.text = "%.1f/s" % pm.hp_regen
	enhanced_hp.text = "%.1f%%" % pm.enhanced_hp_gain
	
	# Movement Stats
	walk_speed.text = "%.1f" % pm.walk_speed
	sprint_speed.text = "%.1f" % pm.sprint_speed
	jump_height.text = "%.1f" % pm.jump_height
	
	# Crit Stats (assuming critical_strike_chance is 0.0-1.0, convert to %)
	crit_chance.text = "%.0f%%" % (pm.critical_strike_chance)
	crit_dmg.text = "%.0f%%" % pm.critical_strike_dmg
	
	# Misc Stats
	life_steal.text = "%.1f%%" % pm.life_steal
	gold_gain.text = "%.1f%%" % pm.enhanced_gold_gain
	pickup_range.text = "%.2fm" % pm.pickup_range
	luck.text = "%.0f" % pm.luck


func open_lvlup_menu(level):
	print(Global.world.elapsed_time)
	rewards = Global.rewardGenerator.generate_rewards()
	print(rewards)
	
	fill_labels()
	fill_reward_slots()
	
	
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


func fill_reward_slots():
	for i in reward_slots:
		i.queue_free()
	
	reward_slots = []
	
	for i in range(3):
		var curr_slot = reward_slot.instantiate()
		curr_slot.setup(i, rewards[i])
		reward_slots.append(curr_slot)
		
		rewards_vbox.add_child(curr_slot)
		

func choose_reward(slot: int) -> void:
	print("Choose reward " + str(slot + 1))
	
	if rewards[slot] is Spell:
		print("ADD SPELL")
		SpellLibrary.add_spell_auto(rewards[slot])
	elif rewards[slot] is Resource:
		print("ADD WAND")
		print(rewards[slot])
	else:
		print("ADD STAT")
		Global.playerManager.upgrade_stat(rewards[slot])
		
	
	close_lvlup_menu()

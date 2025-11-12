extends Control

@onready var lvl_num: Label = $PanelContainer/Control/LvlNum

@onready var rewards_vbox: VBoxContainer = $PanelContainer/Control/PanelContainer2/MarginContainer/VBoxContainer/RewardsVbox
@onready var reroll_box: PanelContainer = $PanelContainer/Control/PanelContainer2/MarginContainer/VBoxContainer/RewardsVbox/RerollBox
@onready var reroll_btn: Button = $PanelContainer/Control/PanelContainer2/MarginContainer/VBoxContainer/RewardsVbox/RerollBox/MarginContainer/PanelContainer/Button

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
var pending_levels: int = 0
var next_level_to_show: int = 0

var rerolls
var curr_reroll_amt

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
	# If we're not already showing menus, start from current level
	if pending_levels == 0:
		next_level_to_show = level - 1  # start from previous level
	
	pending_levels += 1
	
	# If already leveling up, don't open another one yet
	if is_leveling_up:
		return

	_show_next_levelup()
	
func _show_next_levelup():
	next_level_to_show += 1  # increment one level at a time
	is_leveling_up = true
	get_tree().paused = true
	Global.paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	visible = true
	
	setup_reroll()
	setup_rewards()
	fill_labels()

	lvl_num.text = str(next_level_to_show)



func setup_rewards():
	rewards = Global.rewardGenerator.generate_rewards()
	print(rewards)
	fill_labels()
	fill_reward_slots()

func setup_reroll():
	curr_reroll_amt = Global.playerManager.reroll_amt
	reroll_btn.text = "REROLL - $%.0f" % curr_reroll_amt
	
	if Global.playerManager.gold < curr_reroll_amt:
		reroll_btn.disabled = true
	else:
		reroll_btn.disabled = false

func close_lvlup_menu():
	is_leveling_up = false
	visible = false
	get_tree().paused = false
	Global.paused = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func fill_reward_slots():
	for i in reward_slots:
		i.queue_free()
	
	reward_slots = []
	
	for i in range(3):
		var curr_slot = reward_slot.instantiate()
		curr_slot.setup(i, rewards[i][0], rewards[i][1])
		reward_slots.append(curr_slot)
		
		rewards_vbox.add_child(curr_slot)
		rewards_vbox.move_child(curr_slot, 0)

func choose_reward(slot: int) -> void:
	print("Choose reward " + str(slot + 1))
	
	if rewards[slot][0] is Spell:
		if SpellLibrary.add_spell_auto(rewards[slot][0]):
			print("ADDED SPELL SUCCESSFULLY")
		else:
			print("SPELL INV FULL")

	elif rewards[slot][0] is Resource:
		if Global.wandInventory.add_wand_auto(rewards[slot][0]):
			print("ADDED WAND SUCCESSFULLY")
		else:
			print("WANDS ARE FULL")
	else:
		print("ADD STAT")
		Global.playerManager.upgrade_stat(rewards[slot][0])
	
	# Handle next level-up
	pending_levels -= 1
	if pending_levels > 0:
		_show_next_levelup()
	else:
		close_lvlup_menu()


func _on_reroll() -> void:
	Global.playerManager.remove_gold(curr_reroll_amt)
	curr_reroll_amt *= 2
	reroll_btn.text = "REROLL - $%.0f" % curr_reroll_amt
	
	setup_rewards()
	
	if Global.playerManager.gold < curr_reroll_amt:
		reroll_btn.disabled = true

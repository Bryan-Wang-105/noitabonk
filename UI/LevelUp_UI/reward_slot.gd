extends PanelContainer

@onready var stat_icon: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/TextureRect
@onready var stat_name: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/StatName
@onready var amt: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Amt
@onready var amounts: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Amounts

@onready var level: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/Level

@onready var bg_container: PanelContainer = $MarginContainer/PanelContainer

var is_what = -1
var load_texture
var load_stat_name
var load_amounts
var load_desc
var indx = -1
var bg_style_box
var lvl 

func _ready():
	stat_icon.texture = load_texture
	stat_name.text = load_stat_name
	level.text = lvl
	
	# Stat
	if is_what == 0:
		amounts.text = load_amounts
	# wand
	elif is_what == 1:
		amt.visible = false
		amounts.text = load_amounts
	else:
		amt.text = load_desc
		amounts.visible = false
		
	bg_container.add_theme_stylebox_override("panel", bg_style_box)
	

func setup(indx_in, obj, tier):
	indx = indx_in
	print("CURRENT")
	print(obj)
	
	setup_rarity_color(tier)
	
	if obj is Array:
		print("STAT")
		is_what = 0
		# if array stat_name -> curr amt -> amt increase
		load_texture = load("res://UI/LevelUp_UI/BaseStatIcons/" + obj[0] + ".png")
		load_stat_name = clean_name(obj[0])
		
		if obj[1] < 1:
			var rounded_stat_before = int(obj[1] * 100)
			var rounded_stat_after = int((obj[1] + obj[2]) * 100)
			load_amounts = str(rounded_stat_before) + "% → " + str(rounded_stat_after) + "%"
		else:
			load_amounts= str(obj[1]) + " → " + str(obj[1] + obj[2])
	
	elif obj is Resource:
		print("WAND")
		is_what = 1
		load_texture = load("uid://v2nhjxlojfki")
		load_stat_name= "Random Wand"

		load_amounts = "DMG_MLT: %.2f  C_DLY: %.2fs  RLD: %.2fs\nCAP: %.0f  SPRD: %.2f" % \
			[obj.dmg_mult, obj.cast_delay, obj.reload_speed, obj.capacity, obj.spread]
		
	elif obj is Spell:
		print("SPELL")
		is_what = 2
		load_stat_name = obj.name + " Spell"
		load_texture = load(obj.icon_path)
		load_desc = obj.description
	else:
		print("ERROR HAPPENING EITHER PERK OR WAND OR SPELL?")
		#print(obj.get_class())

func setup_rarity_color(tier):
	
	# Get the stylebox from the PanelContainer
	var stylebox = get_theme_stylebox("panel").duplicate()
	
	bg_style_box = get_theme_stylebox("panel").duplicate()

	# Set color based on tier
	if tier == 1:
		lvl = "Common Reward"
		stylebox.bg_color = SpellLibrary.rarity_color["Common"]
		bg_style_box.bg_color = SpellLibrary.rarity_color["Common"].darkened(0.6)
	elif tier == 2:
		lvl = "Uncommon Reward"
		stylebox.bg_color = SpellLibrary.rarity_color["Uncommon"]
		bg_style_box.bg_color = SpellLibrary.rarity_color["Uncommon"].darkened(0.6)
	elif tier == 3:
		lvl = "Rare Reward"
		stylebox.bg_color = SpellLibrary.rarity_color["Rare"]
		bg_style_box.bg_color = SpellLibrary.rarity_color["Rare"].darkened(0.6)
	
	# Apply the modified stylebox back to the panel
	add_theme_stylebox_override("panel", stylebox)


func clean_name(stat: String):
	match stat:
		# Health stats
		"max_health":
			return "Max Health"
		"hp_regen":
			return "HP Regen"
		"enhanced_xp_gain":
			return "Enhanced XP Gain"
		"enhanced_hp_gain":
			return "Enhanced HP Gain"
		
		# Movement stats
		"walk_speed":
			return "Walk Speed"
		"sprint_speed":
			return "Sprint Speed"
		"jump_height":
			return "Jump Height"
		
		# Crit stats
		"critical_strike_chance":
			return "Critical Strike Chance"
		"critical_strike_dmg":
			return "Critical Strike Damage"
		
		# Misc stats
		"life_steal":
			return "Vampirism"
		"luck":
			return "Luck"
		"enhanced_gold_gain":
			return "Gold Gain"
		"pickup_range":
			return "Pickup Range"


func _on_button_pressed() -> void:
	Global.canvas_layer.level_up_ui.choose_reward(indx)

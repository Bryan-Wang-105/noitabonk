extends PanelContainer

@onready var stat_icon: TextureRect = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/TextureRect
@onready var stat_name: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/StatName
@onready var amt: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Amt
@onready var amounts: Label = $MarginContainer/PanelContainer/MarginContainer/HBoxContainer/MarginContainer/VBoxContainer/HBoxContainer/Amounts


var is_what = -1
var load_texture
var load_stat_name
var load_amounts
var load_desc
var indx = -1

func _ready():
	stat_icon.texture = load_texture
	stat_name.text = load_stat_name
	
	# Stat
	if is_what == 0:
		amounts.text = load_amounts
	# wand
	elif is_what == 1:
		amt.visible = false
		amounts.visible = false
	else:
		amt.text = load_desc
		amounts.visible = false
	

func setup(indx_in, obj):
	indx = indx_in
	print("CURRENT")
	print(obj)
	if obj is Array:
		print("STAT")
		is_what = 0
		# if array stat_name -> curr amt -> amt increase
		load_texture = load("res://UI/LevelUp_UI/BaseStatIcons/" + obj[0] + ".png")
		load_stat_name = clean_name(obj[0])
		load_amounts= str(obj[1]) + " → " + str(obj[1] + obj[2])
	
	elif obj is Resource:
		print("WAND")
		is_what = 1
		load_texture = load("uid://v2nhjxlojfki")
		load_stat_name= "New RNG Wand"
		
	elif obj is Spell:
		print("SPELL")
		is_what = 2
		load_stat_name = obj.name + " Spell"
		load_texture = load(obj.icon_path)
		load_desc = obj.description
	else:
		print(obj.get_class())
		print("ERROR HAPPENING EITHER PERK OR WAND OR SPELL?")

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
		"gold_gain":
			return "Gold Gain"
		"pickup_range":
			return "Pickup Range"


func _on_button_pressed() -> void:
	Global.canvas_layer.level_up_ui.choose_reward(indx)

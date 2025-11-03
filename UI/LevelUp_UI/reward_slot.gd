extends PanelContainer

@onready var stat_icon: TextureRect = $MarginContainer/PanelContainer/MarginContainer/Control/TextureRect
@onready var stat_name: Label = $MarginContainer/PanelContainer/MarginContainer/Control/StatName
@onready var amounts: Label = $MarginContainer/PanelContainer/MarginContainer/Control/Amounts

var load_texture
var load_stat_name
var load_amounts

func _ready():
	stat_icon.texture = load_texture
	stat_name.text = load_stat_name
	
	if load_amounts:
		amounts.text = load_amounts

func setup(obj):
	print("CURRENT")
	print(obj)
	if obj is Array:
		print("STAT")
		# if array stat_name -> curr amt -> amt increase
		load_texture = load("res://UI/LevelUp_UI/BaseStatIcons/" + obj[0] + ".png")
		load_stat_name = clean_name(obj[0])
		load_amounts= str(obj[1]) + " → " + str(obj[1] + obj[2])
	
	elif obj is Resource:
		print("WAND")
		load_texture = load("uid://v2nhjxlojfki")
		load_stat_name= "New RNG Wand"
		
	elif obj is Spell:
		print("SPELL")
		load_stat_name = obj.name + " Spell"
		load_texture = load(obj.icon_path)
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
			return "Life Steal"
		"luck":
			return "Luck"
		"gold_gain":
			return "Gold Gain"
		"pickup_range":
			return "Pickup Range"

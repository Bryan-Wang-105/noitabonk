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
		load_stat_name = obj[0]
		load_amounts= str(obj[1]) + " → " + str(obj[1] + obj[2])
	elif obj is Wand:
		print("WAND")
		load_stat_name= "New random wand"
		
	elif obj is Spell:
		print("SPELL")
		load_stat_name = "New random spell"
		load_texture = load(obj.icon_path)
	

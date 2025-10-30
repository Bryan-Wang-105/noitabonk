extends PanelContainer

@onready var spell_name: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/Name
@onready var texture_rect: TextureRect = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/TextureRect
@onready var dmg: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer2/DMG
@onready var cstdly: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/VBoxContainer2/CSTDLY
@onready var desc: Label = $MarginContainer/Panel/MarginContainer/VBoxContainer/DESC


func _ready() -> void:
	visible = false

func setup(spell_info):
	spell_name.text = spell_info[0]
	texture_rect.texture = load(spell_info[1])
	dmg.text = str(spell_info[2])
	cstdly.text = str(spell_info[3])
	desc.text = spell_info[4]

func clear():
	spell_name.text = ""
	texture_rect.texture = null
	dmg.text = ""
	cstdly.text = ""
	desc.text = ""

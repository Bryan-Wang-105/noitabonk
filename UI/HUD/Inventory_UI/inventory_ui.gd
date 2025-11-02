extends PanelContainer

@onready var wands_panel: MarginContainer = $"MarginContainer/Panel/InventoryHbox/Wands Panel"
@onready var inventory_grid: GridContainer = $MarginContainer/Panel/InventoryHbox/MarginContainer2/VBoxContainer2/GridContainer

@onready var inventory_page: HBoxContainer = $MarginContainer/Panel/InventoryHbox
@onready var stats_page: HBoxContainer = $MarginContainer/Panel/StatsPage


@onready var inventory_btn: Button = $Control/InventoryBtn
@onready var perks_stats_btn: Button = $Control/PerksStatsBtn

var spell_inventory_slots = []
var is_inventory = true

func _ready():
	visible = false
	
	inventory_btn.add_theme_font_size_override("font_size", 32)
	perks_stats_btn.add_theme_font_size_override("font_size", 24)
	
	
	stats_page.visible = false
	inventory_page.visible = true
	
	generate_inventory_grid()
	
	Global.wandInventory.connect("inventory_changed", update_inventory_grid)
	SpellLibrary.connect("spell_inventory_changed", update_inventory_grid)

func show_hide():
	visible = !visible


func generate_inventory_grid():
	for i in range(len(SpellLibrary.inventory_spells)):
		var spellSlotPanel = load("uid://cttoi0mn1tgww").instantiate()
		
		# Pass in slot index
		spellSlotPanel.setup_inventory_slot(i)
		
		spell_inventory_slots.append(spellSlotPanel)
		
		if SpellLibrary.inventory_spells[i]:
			print("HAS INVENTORY SPELLS ON GENERATE")
			var spellUI_element = load("uid://bh51pyfnfc4dg").instantiate()
			spellUI_element.setup(SpellLibrary.inventory_spells[i])
			
			spellSlotPanel.add_child(spellUI_element)
			spellSlotPanel.spell_UI = spellUI_element
		
		
		inventory_grid.add_child(spellSlotPanel)

func update_inventory_grid():
	for i in range(len(SpellLibrary.inventory_spells)):
		var check_spell = spell_inventory_slots[i].spell_UI
		var curr_spell = SpellLibrary.inventory_spells[i]
		
		if check_spell == null and curr_spell != null:
			print("DIFF FOUND BETWEEN INVENTORY AND SLOT")
			var spellUI_element = load("uid://bh51pyfnfc4dg").instantiate()
			spellUI_element.setup(curr_spell)

			spell_inventory_slots[i].add_child(spellUI_element)
			spell_inventory_slots[i].spell_UI = spellUI_element


# 0 is inventory / 1 is perks/stats
func _change_menu_btn(change_to_menu) -> void:
	print("Changed Menus")
	if change_to_menu == 1:
		print("Changing to PERKS and STATS")
		inventory_btn.add_theme_font_size_override("font_size", 24)
		perks_stats_btn.add_theme_font_size_override("font_size", 32)
		
		inventory_page.visible = false
		stats_page.visible = true
		
	else:
		print("Changing to INVENTORY")
		inventory_btn.add_theme_font_size_override("font_size", 32)
		perks_stats_btn.add_theme_font_size_override("font_size", 24)
		
		
		inventory_page.visible = true
		stats_page.visible = false

	is_inventory = !is_inventory

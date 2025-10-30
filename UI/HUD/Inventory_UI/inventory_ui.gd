extends PanelContainer

@onready var wands_panel: MarginContainer = $"MarginContainer/Panel/HBoxContainer/Wands Panel"
@onready var inventory_grid: GridContainer = $MarginContainer/Panel/HBoxContainer/MarginContainer2/VBoxContainer2/GridContainer

var spell_inventory_slots = []

func _ready():
	visible = false
	
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

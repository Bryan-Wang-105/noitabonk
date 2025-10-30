extends Panel


var spell_UI = null

var parent_array = null

var is_inventory = false

var is_wand = false
var wand_index = -1

var slot_index

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP  # Enable mouse detection

func setup_wand_slot(wand_indx, slot_indx):
	is_wand = true
	wand_index = wand_indx
	slot_index = slot_indx
	parent_array = Global.wandInventory.wands[wand_indx].spells

func setup_inventory_slot(slot_indx):
	is_inventory = true
	slot_index = slot_indx
	parent_array = SpellLibrary.inventory_spells

func add_spell_object(new_spell_in):
	if is_inventory:
		print("Adding spell to INVENTORY SLOT " + str(slot_index))
		SpellLibrary.add_spell(slot_index, new_spell_in.spell)
	else:
		print("Adding spell to WAND SLOT " + str(slot_index))
		Global.wandInventory.add_spell_to_wand(wand_index, slot_index, new_spell_in.spell)
		
		spell_UI = new_spell_in
		add_child(spell_UI)

func remove_spell_object():
	remove_child(spell_UI)
	spell_UI = null
	
	if is_inventory:
		print("Removing spell from INVENTORY SLOT " + str(slot_index))
		SpellLibrary.remove_spell(slot_index)
	else:
		print("Removing spell from WAND SLOT " + str(slot_index))
		Global.wandInventory.remove_spell_from_wand(wand_index, slot_index)

# Godot calls this when something is dragged over THIS node
func _can_drop_data(at_position: Vector2, data) -> bool:
	# Return true if you accept this data
	print("CAN DROP DATA")
	
	return true

# Godot calls this when data is dropped on THIS node
func _drop_data(at_position: Vector2, data) -> void:
	print("DROPPED DATA")
	
	# Need to add backend logic to update the missing spell from the wand or
	# the inventory
	if data.get_parent():
		data.get_parent().remove_spell_object()

	add_spell_object(data)

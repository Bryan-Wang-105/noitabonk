# WandInventory.gd
extends Node
class_name WandInventory

const MAX_WANDS: int = 4

# Array of 4 wand slots
var wands: Array[WandData] = []
var active_slot: int = 0
var active_wand = null


signal inventory_changed(wand_data: WandData, slot: int)
signal wand_equipped(wand_data: WandData, slot: int)
signal wand_added(wand_data: WandData, slot: int)
signal wand_removed(slot: int)

func _ready() -> void:
	Global.wandInventory = self
	# Initialize empty inventory
	wands.resize(MAX_WANDS)

func _input(event: InputEvent) -> void:
	# Handle wand switching (1-4 keys)
	if event.is_action_pressed("wand_1"):
		equip_wand(0)
		emit_signal("inventory_changed")
	elif event.is_action_pressed("wand_2"):
		equip_wand(1)
		emit_signal("inventory_changed")
	elif event.is_action_pressed("wand_3"):
		equip_wand(2)
		emit_signal("inventory_changed")
	elif event.is_action_pressed("wand_4"):
		equip_wand(3)
		emit_signal("inventory_changed")

# Equip a wand from a specific slot
func equip_wand(slot: int) -> void:
	if slot < 0 or slot >= MAX_WANDS:
		return
	
	if wands[slot] == null:
		print("No wand in slot ", slot)
		return
	
	active_slot = slot
	active_wand = wands[slot]
	wand_equipped.emit(wands[slot], slot)
	
	emit_signal("inventory_changed")
	print("Equipped wand from slot ", slot)

# Add a wand to specific slot
func add_wand(wand_data: WandData, slot: int) -> bool:
	if slot < 0 or slot >= MAX_WANDS:
		return false
	
	wands[slot] = wand_data
	wand_added.emit(wand_data, slot)
	
	# Auto-equip if it's the first wand
	if get_wand_count() == 1:
		equip_wand(slot)
	
	
	emit_signal("inventory_changed")
	return true

# Add wand to first available slot
func add_wand_auto(wand_data: WandData) -> bool:
	for i in range(MAX_WANDS):
		if wands[i] == null:
			emit_signal("inventory_changed")
			return add_wand(wand_data, i)
	return false  # Inventory full

# Remove wand from slot
func remove_wand(slot: int) -> WandData:
	if slot < 0 or slot >= MAX_WANDS:
		return null
	
	var removed_wand = wands[slot]
	wands[slot] = null
	wand_removed.emit(slot)
	
	# If we removed the active wand, try to equip another
	if slot == active_slot:
		find_next_wand()
	
	emit_signal("inventory_changed")
	return removed_wand

# Get currently equipped wand
func get_active_wand() -> WandData:
	return wands[active_slot]

# Get wand from specific slot
func get_wand(slot: int) -> WandData:
	if slot >= 0 and slot < MAX_WANDS:
		return wands[slot]
	return null

# Count non-null wands
func get_wand_count() -> int:
	var count = 0
	for wand in wands:
		if wand != null:
			count += 1
	return count

# Find and equip the next available wand
func find_next_wand() -> void:
	for i in range(MAX_WANDS):
		if wands[i] != null:
			equip_wand(i)
			return
	
	# No wands available
	wand_equipped.emit(null, -1)

func add_spell_to_wand(wand_index, slot_index, spell):
	wands[wand_index].spells[slot_index] = spell

func remove_spell_from_wand(wand_index, slot_index):
	wands[wand_index].spells[slot_index] = null

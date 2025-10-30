extends CanvasLayer

@onready var wand_controller: WandController = $"../WandController"
@onready var wand_inventory: WandInventory = $"../WandInventory"

@onready var fps: Label = $Control/FPS
@onready var cast: Label = $Control/Cast
@onready var reload: Label = $Control/Reload

@onready var wand_1: Label = $Control/HBoxContainer/Wand1
@onready var wand_2: Label = $Control/HBoxContainer/Wand2
@onready var wand_3: Label = $Control/HBoxContainer/Wand3
@onready var wand_4: Label = $Control/HBoxContainer/Wand4

var wand_labels

@onready var preview: PanelContainer = $Preview

@onready var rrty: Label = $Preview/MarginContainer/VBoxContainer/HBoxContainer/RRTY2
@onready var dmg: Label = $Preview/MarginContainer/VBoxContainer/HBoxContainer2/DMG2
@onready var cdly: Label = $Preview/MarginContainer/VBoxContainer/HBoxContainer3/CDLY2
@onready var rldspd: Label = $Preview/MarginContainer/VBoxContainer/HBoxContainer4/RLDSPD2
@onready var sprd: Label = $Preview/MarginContainer/VBoxContainer/HBoxContainer5/SPRD2
@onready var cpcty: Label = $Preview/MarginContainer/VBoxContainer/HBoxContainer6/CPCTY2
@onready var spellsVbox: VBoxContainer = $Preview/MarginContainer/VBoxContainer/VBoxContainer

@onready var inventory: PanelContainer = $Inventory

@onready var inventory_grid: GridContainer = $Inventory/MarginContainer/Panel/HBoxContainer/MarginContainer2/VBoxContainer2/GridContainer

@onready var previewWand: PanelContainer = $PreviewWand
var preview_positions = [[936,181], [936,415], [936, 220], [936, 425]]

@onready var rrty_2: Label = $PreviewWand/MarginContainer/VBoxContainer/HBoxContainer/RRTY2
@onready var dmg_2: Label = $PreviewWand/MarginContainer/VBoxContainer/HBoxContainer2/DMG2
@onready var cdly_2: Label = $PreviewWand/MarginContainer/VBoxContainer/HBoxContainer3/CDLY2
@onready var rldspd_2: Label = $PreviewWand/MarginContainer/VBoxContainer/HBoxContainer4/RLDSPD2
@onready var sprd_2: Label = $PreviewWand/MarginContainer/VBoxContainer/HBoxContainer5/SPRD2
@onready var cpcty_2: Label = $PreviewWand/MarginContainer/VBoxContainer/HBoxContainer6/CPCTY2

@export var spellSlotScene: PackedScene
@export var spellScene: PackedScene

@onready var spell_preview: PanelContainer = $SpellPreview

var mouse_on = false
var mouse_on_slot = null

var dragging_spell = false

var spell_inventory_slots = []

func _ready():
	return
	#Global.canvas_layer = self
	previewWand.visible = false
	inventory.visible = false
	preview.visible = false
	wand_inventory.connect("inventory_changed", update_inventory)
	SpellLibrary.connect("spell_inventory_changed", update_inventory)
	generate_inventory_grid()
	
	wand_labels = [wand_1, wand_2, wand_3, wand_4]

func showHide_inventory():
	update_inventory_grid()
	inventory.visible = !inventory.visible

func _process(delta: float) -> void:
	fps.text = "FPS: " + str(Engine.get_frames_per_second())
	cast.text = "Cast Delay: %.2f" % (wand_controller.cast_delay_timer)
	reload.text = "Reload Time: %.2f" % (wand_controller.reload_timer)

func update_inventory():
	for i in range(wand_inventory.MAX_WANDS):
		if wand_inventory.wands[i]:
			wand_labels[i].text = "Wand " + str(i + 1)
		if wand_inventory.active_slot == i:
			wand_labels[i].text = "ACTIVE\nWand " + str(i + 1)
	
	print("Updating inventory grid")
	update_inventory_grid()
	
	# UPDATE WAND PANEL PREVIEW CHECKER
	if mouse_on:
		_on_wand_box_mouse_entered(mouse_on_slot)

func generate_inventory_grid():
	for i in range(len(SpellLibrary.inventory_spells)):
		var spellSlotPanel = spellSlotScene.instantiate()
		
		# Pass in slot index
		spellSlotPanel.setup_inventory_slot(i)
		
		spell_inventory_slots.append(spellSlotPanel)
		
		if SpellLibrary.inventory_spells[i]:
			print("HAS INVENTORY SPELLS ON GENERATE")
			var spellUI_element = spellScene.instantiate()
			spellUI_element.setup(SpellLibrary.inventory_spells[i])
			
			spellSlotPanel.add_child(spellUI_element)
			spellSlotPanel.spell_UI = spellUI_element
		
		
		inventory_grid.add_child(spellSlotPanel)

func update_inventory_grid():
	for i in range(len(SpellLibrary.inventory_spells)):
		var check_spell = spell_inventory_slots[i].spell_UI
		var curr_spell = SpellLibrary.inventory_spells[i]
		
		#print("CHECK + CURR")
		#print(check_spell)
		#print(curr_spell)
		
		if check_spell == null and curr_spell != null:
			print("DIFF FOUND BETWEEN INVENTORY AND SLOT")
			var spellUI_element = spellScene.instantiate()
			spellUI_element.setup(curr_spell)

			spell_inventory_slots[i].add_child(spellUI_element)
			spell_inventory_slots[i].spell_UI = spellUI_element


func show_item_preview(stats):
	preview.visible = true
	
	var active_wand = Global.wandInventory.wands[Global.wandInventory.active_slot]
	
	# Rarity
	rrty.text = stats[5]
	match rrty.text:
		"Common":
			rrty.add_theme_color_override("font_color", Color.GRAY)
		"Uncommon":
			rrty.add_theme_color_override("font_color", Color.GREEN)
		"Rare":
			rrty.add_theme_color_override("font_color", Color.SKY_BLUE)
	
	# Damage
	dmg.text = "%.2f" % stats[0]
	set_stat_color(dmg, stats[0], active_wand.dmg_mult)
	
	# Cooldown (lower is better, so reverse the comparison)
	cdly.text = "%.2f" % stats[1]
	set_stat_color(cdly, stats[1], active_wand.cast_delay, true)
	
	# Reload Speed (lower is better)
	rldspd.text = "%.2f" % stats[2]
	set_stat_color(rldspd, stats[2], active_wand.reload_speed, true)
	
	# Spread (lower is better)
	sprd.text = "%.2f" % stats[3]
	set_stat_color(sprd, stats[3], active_wand.spread, true)
	
	# Capacity
	cpcty.text = str(stats[4])
	set_stat_color(cpcty, stats[4], active_wand.capacity)
	
	# Spells - display spell slots
	display_spell_slots(stats[6], stats[4])  # Pass spells array and capacity
	
func display_spell_slots(spells: Array, capacity: int):
	# Clear existing spell rows
	for child in spellsVbox.get_children():
		if child != $Preview/MarginContainer/VBoxContainer/VBoxContainer/SPELLS:
			child.queue_free()
	
	var slots_per_row = 8
	var total_rows = ceil(float(capacity) / slots_per_row)
	
	# Create rows as needed
	for row_index in range(total_rows):
		var row_hbox = HBoxContainer.new()
		row_hbox.mouse_filter = Control.MOUSE_FILTER_PASS
		row_hbox.add_theme_constant_override("separation", 6)  # Spacing between slots
		
		# Calculate how many slots in this row
		var start_index = row_index * slots_per_row
		var end_index = min(start_index + slots_per_row, capacity)
		
		# Create slots for this row
		for i in range(start_index, end_index):
			var spellSlotPanel = spellSlotScene.instantiate()
			if i < spells.size() and spells[i] != null:
				
				var spellUI_element = spellScene.instantiate()
				spellUI_element.setup(spells[i])

				spellSlotPanel.add_child(spellUI_element)
				spellSlotPanel.spell_UI = spellUI_element
				
			
			row_hbox.add_child(spellSlotPanel)
			
		spellsVbox.add_child(row_hbox)

func set_stat_color(label, new_value, current_value, lower_is_better = false):
	if lower_is_better:
		if new_value < current_value:
			label.add_theme_color_override("font_color", Color.GREEN)
		elif new_value > current_value:
			label.add_theme_color_override("font_color", Color.RED)
		else:
			label.add_theme_color_override("font_color", Color.WHITE)
	else:
		if new_value > current_value:
			label.add_theme_color_override("font_color", Color.GREEN)
		elif new_value < current_value:
			label.add_theme_color_override("font_color", Color.RED)
		else:
			label.add_theme_color_override("font_color", Color.WHITE)

func hide_item_preview():
	preview.visible = false


func _on_wand_box_mouse_entered(wand_slot) -> void:
	mouse_on = true
	mouse_on_slot = wand_slot
	
	print("HOVERING WAND " + str(wand_slot))
	
	previewWand.position.x = preview_positions[wand_slot][0]
	previewWand.position.y = preview_positions[wand_slot][1]
	
	var active_wand = Global.wandInventory.wands[Global.wandInventory.active_slot]
	var stats = Global.wandInventory.wands[wand_slot]
	
	print("ACTIVE SLOT " + str(Global.wandInventory.active_slot))
	print("COMPARE SLOT " + str(wand_slot))
	
	if not stats or not active_wand:
		return
	else:
		stats = stats.get_stats()
		
	# Rarity
	rrty_2.text = stats[5]
	match rrty_2.text:
		"Common":
			rrty_2.add_theme_color_override("font_color", Color.GRAY)
		"Uncommon":
			rrty_2.add_theme_color_override("font_color", Color.GREEN)
		"Rare":
			rrty_2.add_theme_color_override("font_color", Color.SKY_BLUE)
		
	# Damage
	dmg_2.text = format_stat_with_diff(stats[0], active_wand.dmg_mult, 2)
	set_stat_color(dmg_2, stats[0], active_wand.dmg_mult)
	
	# Cooldown (lower is better, so reverse=true)
	cdly_2.text = format_stat_with_diff(stats[1], active_wand.cast_delay, 2, true)
	set_stat_color(cdly_2, stats[1], active_wand.cast_delay, true)

	# Reload Speed (lower is better)
	rldspd_2.text = format_stat_with_diff(stats[2], active_wand.reload_speed, 2, true)
	set_stat_color(rldspd_2, stats[2], active_wand.reload_speed, true)

	# Spread (lower is better)
	sprd_2.text = format_stat_with_diff(stats[3], active_wand.spread, 2, true)
	set_stat_color(sprd_2, stats[3], active_wand.spread, true)

	# Capacity (no decimals)
	cpcty_2.text = format_stat_with_diff(stats[4], active_wand.capacity, 0)
	set_stat_color(cpcty_2, stats[4], active_wand.capacity)
	
	previewWand.visible = true
	pass # Replace with function body.

func _on_wand_box_mouse_exited(wand_slot) -> void:
	mouse_on = false
	mouse_on_slot = null
	
	previewWand.visible = false
	print("EXITING WAND " + str(wand_slot))
	pass # Replace with function body.


# Helper function to format stat with difference
func format_stat_with_diff(new_value, old_value, decimals: int = 2, reverse: bool = false) -> String:
	var diff = new_value - old_value
	var sign = ""
	var color_code = ""
	
	# Determine if change is good or bad
	var is_improvement = (diff > 0 and not reverse) or (diff < 0 and reverse)
	
	if diff > 0:
		sign = "+"
	elif diff < 0:
		sign = ""  # Negative sign already included
	else:
		return "%.{0}f".format([decimals]) % new_value  # No change, no diff shown
	
	# Format the output
	if decimals == 0:
		return "%d  (%s %d)" % [new_value, sign, diff]
	else:
		return "%.{0}f  (%s %.{0}f)".format([decimals]) % [new_value, sign, diff]

func toggle_drag():
	print("DRAGGING TOGGLE EMITTED")
	dragging_spell = !dragging_spell

extends PanelContainer

@onready var rrty: Label = $MarginContainer/VBoxContainer/HBoxContainer/RRTY2
@onready var dmg: Label = $MarginContainer/VBoxContainer/HBoxContainer2/DMG2
@onready var cdly: Label = $MarginContainer/VBoxContainer/HBoxContainer3/CDLY2
@onready var rldspd: Label = $MarginContainer/VBoxContainer/HBoxContainer4/RLDSPD2
@onready var sprd: Label = $MarginContainer/VBoxContainer/HBoxContainer5/SPRD2
@onready var cpcty: Label = $MarginContainer/VBoxContainer/HBoxContainer6/CPCTY2
@onready var spellsVbox: VBoxContainer = $MarginContainer/VBoxContainer/VBoxContainer

func _ready() -> void:
	visible = false

func show_item_preview(stats):
	visible = true
	
	var active_wand = Global.wandInventory.wands[Global.wandInventory.active_slot]
	
	# Rarity
	rrty.text = stats[5]
	match rrty.text:
		"Common":
			rrty.add_theme_color_override("font_color", SpellLibrary.rarity_color["Common"])
		"Uncommon":
			rrty.add_theme_color_override("font_color", SpellLibrary.rarity_color["Uncommon"])
		"Rare":
			rrty.add_theme_color_override("font_color", SpellLibrary.rarity_color["Rare"])
	
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
		if child != $MarginContainer/VBoxContainer/VBoxContainer/SPELLS:
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
			var spellSlotPanel = load("uid://cttoi0mn1tgww").instantiate()
			if i < spells.size() and spells[i] != null:
				
				var spellUI_element = load("uid://bh51pyfnfc4dg").instantiate()
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
	visible = false

extends PanelContainer

@onready var rrty: Label = $MarginContainer/VBoxContainer/HBoxContainer/RRTY2
@onready var dmg: Label = $MarginContainer/VBoxContainer/HBoxContainer2/DMG2
@onready var cdly: Label = $MarginContainer/VBoxContainer/HBoxContainer3/CDLY2
@onready var rldspd: Label = $MarginContainer/VBoxContainer/HBoxContainer4/RLDSPD2
@onready var sprd: Label = $MarginContainer/VBoxContainer/HBoxContainer5/SPRD2
@onready var cpcty: Label = $MarginContainer/VBoxContainer/HBoxContainer6/CPCTY2


var preview_positions = [[936,181], [936,415], [936, 220], [936, 425]]

var mouse_on = false
var mouse_on_slot = null

func _ready() -> void:
	visible = false

func _on_wand_box_mouse_entered(wand_slot) -> void:
	mouse_on = true
	mouse_on_slot = wand_slot
	
	print("HOVERING WAND " + str(wand_slot))
	
	position.x = preview_positions[wand_slot][0]
	position.y = preview_positions[wand_slot][1]
	
	var active_wand = Global.wandInventory.wands[Global.wandInventory.active_slot]
	var stats = Global.wandInventory.wands[wand_slot]
	
	print("ACTIVE SLOT " + str(Global.wandInventory.active_slot))
	print("COMPARE SLOT " + str(wand_slot))
	
	if not stats or not active_wand:
		return
	else:
		stats = stats.get_stats()
		
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
	dmg.text = format_stat_with_diff(stats[0], active_wand.dmg_mult, 2)
	set_stat_color(dmg, stats[0], active_wand.dmg_mult)
	
	# Cooldown (lower is better, so reverse=true)
	cdly.text = format_stat_with_diff(stats[1], active_wand.cast_delay, 2, true)
	set_stat_color(cdly, stats[1], active_wand.cast_delay, true)

	# Reload Speed (lower is better)
	rldspd.text = format_stat_with_diff(stats[2], active_wand.reload_speed, 2, true)
	set_stat_color(rldspd, stats[2], active_wand.reload_speed, true)

	# Spread (lower is better)
	sprd.text = format_stat_with_diff(stats[3], active_wand.spread, 2, true)
	set_stat_color(sprd, stats[3], active_wand.spread, true)

	# Capacity (no decimals)
	cpcty.text = format_stat_with_diff(stats[4], active_wand.capacity, 0)
	set_stat_color(cpcty, stats[4], active_wand.capacity)
	
	visible = true
	pass # Replace with function body.

func _on_wand_box_mouse_exited(wand_slot) -> void:
	mouse_on = false
	mouse_on_slot = null
	
	visible = false
	print("EXITING WAND " + str(wand_slot))
	pass # Replace with function body.

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

extends Panel

@onready var txtr: TextureRect = $MarginContainer/TextureRect

var loaded_texture

var spell
var spell_info

signal dragging_toggle

var stylebox: StyleBoxFlat


func _ready() -> void:
	#Global.canvas_layer
	dragging_toggle.emit()
	txtr.texture = loaded_texture
	mouse_filter = Control.MOUSE_FILTER_STOP  # Enable mouse detection
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	
	
	# Connect the gui_input signal
	gui_input.connect(_on_panel_clicked)
	

func _on_panel_clicked(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		# Check if Shift is being held
		if event.shift_pressed:
			print("Panel clicked with Shift held!")
			# Do X here (shift + click behavior)
			
			# Remove spell object from parent
			var parent_slot = get_parent()
			parent_slot.remove_spell_object()
			
			# Add spell object to inventory
			SpellLibrary.add_spell_auto(spell)
			
			
		else:
			print("Panel clicked without Shift")
			# Normal click behavior

func _on_mouse_entered() -> void:
	print("HOVERING SLOT")
	Global.canvas_layer.spell_preview.position.x = global_position.x
	Global.canvas_layer.spell_preview.position.y = global_position.y
	Global.canvas_layer.spell_preview.setup(spell_info)
	Global.canvas_layer.spell_preview.visible = true

func _on_mouse_exited() -> void:
	print("LEAVING SLOT")
	Global.canvas_layer.spell_preview.clear()
	Global.canvas_layer.spell_preview.visible = false
	
	
func setup(spell_in):
	# Take spell in
	spell = spell_in
	
	# Get spell info
	spell_info = spell.get_spell_info()
	
	# Load spell texture
	loaded_texture = load(spell_info[1])
	
	stylebox = get_theme_stylebox("panel")
	stylebox = stylebox.duplicate()
	
	# Change color based on condition
	if spell_in.rarity == "Common":
		stylebox.bg_color = SpellLibrary.rarity_color["Common"]
	elif spell_in.rarity == "Uncommon":
		stylebox.bg_color = SpellLibrary.rarity_color["Uncommon"]
	elif spell_in.rarity == "Rare":
		stylebox.bg_color = SpellLibrary.rarity_color["Rare"]
	
	# Apply the stylebox to the panel
	add_theme_stylebox_override("panel", stylebox)

# Godot calls this when drag starts on THIS node
func _get_drag_data(at_position: Vector2):
	print("DRAGGING NOW")
	
	var preview = txtr.duplicate()
	
	dragging_toggle.emit()
	# This makes it the drag preview
	set_drag_preview(preview)
	
	return self

# Godot calls this when something is dragged over THIS node
func _can_drop_data(at_position: Vector2, data) -> bool:
	print(data)
	
	if data == self:
		print("CAN'T DROP ON SELF")
		return false
	
	else:
		# Return true if you accept this data
		print("CAN DROP DATA")
		return true

# Godot calls this when data is dropped on THIS node
func _drop_data(at_position: Vector2, data) -> void:
	
	var dragged_parent_slot = data.get_parent()
	var curr_parent_slot = get_parent()
	
	# remove data from its parent slot and parent arr
	dragged_parent_slot.remove_spell_object()
	
	# remove the current spell UI we dragged onto (this one) from its parent slot and arr
	curr_parent_slot.remove_spell_object()
	
	# Add new dragged data to curr parent slot and parent arr
	dragged_parent_slot.add_spell_object(self)
	
	# Add current data to dragged parent slot and parent arr
	curr_parent_slot.add_spell_object(data)

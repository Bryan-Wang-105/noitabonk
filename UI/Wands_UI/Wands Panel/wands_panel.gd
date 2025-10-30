extends MarginContainer

@onready var panel1: PanelContainer = $WandsVBOX/Wand1Box
@onready var panel2: PanelContainer = $WandsVBOX/Wand2Box
@onready var panel3: PanelContainer = $WandsVBOX/Wand3Box
@onready var panel4: PanelContainer = $WandsVBOX/Wand4Box

@onready var label1: Label = $WandsVBOX/Wand1Box/MarginContainer/VBoxContainer/Label
@onready var label2: Label = $WandsVBOX/Wand2Box/MarginContainer/VBoxContainer/Label
@onready var label3: Label = $WandsVBOX/Wand3Box/MarginContainer/VBoxContainer/Label
@onready var label4: Label = $WandsVBOX/Wand4Box/MarginContainer/VBoxContainer/Label

@onready var grid_container1: GridContainer = $WandsVBOX/Wand1Box/MarginContainer/VBoxContainer/GridContainer
@onready var grid_container2: GridContainer = $WandsVBOX/Wand2Box/MarginContainer/VBoxContainer/GridContainer
@onready var grid_container3: GridContainer = $WandsVBOX/Wand3Box/MarginContainer/VBoxContainer/GridContainer
@onready var grid_container4: GridContainer = $WandsVBOX/Wand4Box/MarginContainer/VBoxContainer/GridContainer


var wandLabels = []
var wandSlots = []
var wandPanels = []

func _ready():
	Global.wandInventory.connect("inventory_changed", update_inventory)
	wandPanels = [panel1, panel2, panel3, panel4]
	wandLabels = [label1, label2, label3, label4]
	wandSlots = [grid_container1, grid_container2, grid_container3, grid_container4]
	update_inventory()


func update_inventory():
	print("WAND PANEL UPDATING")
	update_wand_labels()
	update_wand_slots()


func update_wand_labels():
	for i in range((Global.wandInventory.MAX_WANDS)):
		if Global.wandInventory.wands[i] != null:
			wandLabels[i].text = "WAND " + str(i + 1) + " - " + Global.wandInventory.wands[i].rarity.to_upper()
		else:
			wandLabels[i].text = "NO WAND"

func update_wand_slots():
	var slots_per_row = 8
			
	for i in range((Global.wandInventory.MAX_WANDS)):
		# Clear existing wand panels
		delete_all_children(wandSlots[i])
		
		var curr_wand = Global.wandInventory.wands[i]
		
		# Get selected wand
		var panel = wandPanels[i]
		var wandPanelStylebox = StyleBoxFlat.new()
		wandPanelStylebox.bg_color = Color(153, 153, 153, 0.1)  # White with 65% alpha
		
		if i == Global.wandInventory.active_slot:
			wandPanelStylebox.bg_color = Color(153, 153, 153, 0.2)  # White with 65% alpha
		
		panel.add_theme_stylebox_override("panel", wandPanelStylebox)
		
		if curr_wand != null:
			print("CREATING A WAND PANEL")
			var spells = curr_wand.spells
			for j in range(curr_wand.capacity):
				print("Creating slot on a wand")
				var spellSlotPanel = load("uid://cttoi0mn1tgww").instantiate()
				
				# Pass in wand indx, slot_indx
				spellSlotPanel.setup_wand_slot(i, j)
				
				
				if j < spells.size() and spells[j] != null:
					print("This slot has a spell")
					var spellUI_element = load("uid://bh51pyfnfc4dg").instantiate()
					spellUI_element.setup(spells[j])
					
					spellSlotPanel.add_child(spellUI_element)
					spellSlotPanel.spell_UI = spellUI_element
				else:
					spellSlotPanel.mouse_filter = Control.MOUSE_FILTER_IGNORE
				
				wandSlots[i].add_child(spellSlotPanel)
				wandSlots[i].add_theme_constant_override("h_separation", 25)
				wandSlots[i].add_theme_constant_override("v_separation", 10)
		
		print(" DONE WITH A WAND ")
		
func delete_all_children(node: Node):
	for child in node.get_children():
		child.queue_free()

func _on_wand_box_mouse_entered(wand_slot):
	Global.canvas_layer.preview_wand_panel._on_wand_box_mouse_entered(wand_slot)

func _on_wand_box_mouse_exited(wand_slot):
	Global.canvas_layer.preview_wand_panel._on_wand_box_mouse_exited(wand_slot)

extends CanvasLayer

# Player HUD
@onready var player_hud: Control = $Player_HUD

# Preview wands on floor to pick up
@onready var wand_preview: PanelContainer = $Wand_Preview

# Preview wands in your inventory in the panels
@onready var preview_wand_panel: PanelContainer = $Preview_Wand_Panel


# Player inventory (Wands + Spells)
@onready var inventory: PanelContainer = $Inventory

# Spell Preview Panel
@onready var spell_preview: PanelContainer = $SpellPreview

func _ready():
	#pass
	Global.canvas_layer = self



func show_item_preview(item_stats):
	wand_preview.show_item_preview(item_stats)
		
func hide_item_preview():
	wand_preview.hide_item_preview()
	
func show_hide_inventory():
	inventory.show_hide()

extends RayCast3D

@onready var player: CharacterBody3D = $"../.."

var prompt_label
var current_item = null

func _ready() -> void:
	prompt_label = Global.canvas_layer.player_hud.prompt_label
	prompt_label.text = ""
	Global.wandInventory.connect("inventory_changed", update_preview)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and is_colliding() and get_collider().is_in_group("interactable"):
		var interactable = get_collider()
		
		interactable.interact()
		#player.is_busy(true)
		prompt_label.text = ""


func _process(delta: float) -> void:
	var collider = get_collider()
	
	if collider and collider.has_method("get_prompt"):
		prompt_label.text = collider.get_prompt()
		
	 # Check if it's an item and if it's DIFFERENT from what we were looking at
		if collider.has_method("loot_wand_preview") and collider != current_item:
			current_item = collider
			Global.canvas_layer.show_item_preview(collider.loot_wand_preview())
			 # Check if it's an item and if it's DIFFERENT from what we were looking at
		elif collider.has_method("loot_spell_preview") and collider != current_item:
			current_item = collider
			
			#Global.canvas_layer.show_item_preview(collider.loot_spell_preview())
	else:
		prompt_label.text = ""
		
		if current_item:
			current_item = null
			Global.canvas_layer.hide_item_preview()
			

func update_preview():
	var collider = get_collider()
	
	if collider and collider.has_method("loot_preview"):
		Global.canvas_layer.show_item_preview(collider.loot_preview())

extends RigidBody3D

var prompt = "[E] to pick up wand"
var loot_wand = null
var already_generated = false

@onready var glow: OmniLight3D = $OmniLight3D4

func _ready() -> void:
	if !already_generated:
		# Base Case of spawn default loot
		generate_random_wand(0)
	
	
	match loot_wand.rarity:
		"Common":
			glow.light_color = Color.GRAY
		"Uncommon":
			glow.light_color = Color.GREEN
		"Rare":
			glow.light_color = Color.BLUE
		"Legendary":
			glow.light_color = Color.ORANGE

func get_prompt():
	return prompt

func interact():
	Global.wandInventory.add_wand_auto(loot_wand)
	print("Wand Added")
	loot_wand.print_wand_stats()
	Global.canvas_layer.hide_item_preview()
	queue_free()

func loot_preview():
	return loot_wand.get_stats()

func generate_random_wand(level):
	loot_wand = WandData.new(level)
	
	already_generated = true

extends RigidBody3D

@export var SPELL: Resource

@onready var sprite: Sprite3D = $Sprite3D
@onready var glow: OmniLight3D = $Sprite3D/OmniLight3D

var spell
var already_generated = false
var prompt = "Press [E] to pick up "

func _ready() -> void:
	if !SPELL:
		# Base Case of spawn default loot
		generate_random_spell()
	else:
		spell = SPELL.new()
	
	sprite.texture = load(spell.icon_path)
	
	match spell.rarity:
		"Common":
			glow.light_color = SpellLibrary.rarity_color["Common"]
		"Uncommon":
			glow.light_color = SpellLibrary.rarity_color["Uncommon"]
		"Rare":
			glow.light_color = SpellLibrary.rarity_color["Rare"]
		"Legendary":
			glow.light_color = Color.ORANGE
	
	prompt += spell.name


func get_prompt():
	return prompt

func interact():
	SpellLibrary.add_spell_auto(spell)
	print("SPELL ADDED")
	queue_free()



func loot_spell_preview():
	return spell.get_spell_info()

func generate_random_spell(rarity = "Random"):
	
	if rarity == "Random":
		spell = SpellLibrary.get_random_spell_up_to_tier("Rare")
	else:
		spell = SpellLibrary.get_random_spell_of_tier(rarity)

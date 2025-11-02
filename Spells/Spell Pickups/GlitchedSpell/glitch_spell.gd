extends RigidBody3D
@export var SPELL: Resource
@onready var sprite: Sprite3D = $Sprite3D
@onready var glow: OmniLight3D = $Sprite3D/OmniLight3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

var spell
var rolled = false
var rolling = false
var already_generated = false
var prompt = "Press [E] to pick up Glitched Spell"
var spell_icons = []

func _ready() -> void:
	grab_spell_icons()
	generate_random_spell()
	pass

func get_prompt():
	return prompt

func interact():
	if rolling:
		return

	if not rolled:
		prompt = ""
		rolling = true
		play_spell_roll_animation()
	
	else:
		SpellLibrary.add_spell_auto(spell)
		print("SPELL ADDED")
		queue_free()

func loot_spell_preview():
	return spell.get_spell_info()

func play_spell_roll_animation():
	sprite.visible = true
	anim_player.play("roll_spell")
	_flash_icons_during_animation()

func _flash_icons_during_animation():
	while anim_player.is_playing():
		_show_random_icon()
		await get_tree().create_timer(0.03).timeout
	
	# Set final icon when animation finishes
	sprite.texture = load(spell.icon_path)
	
	match spell.rarity:
		"Common":
			glow.light_color = SpellLibrary.rarity_color["Common"]
		"Uncommon":
			glow.light_color = SpellLibrary.rarity_color["Uncommon"]
		"Rare":
			glow.light_color = SpellLibrary.rarity_color["Rare"]
	
	anim_player.play("bounce_finish")
	rolling = false
	
	prompt = "Press E to pick up " + spell.name + " Spell"
	rolled = true

func _show_random_icon():
	if spell_icons.size() > 0:
		var random_icon = spell_icons[randi() % spell_icons.size()]
		sprite.texture = load(random_icon)
	
	var rng_color = randi_range(0, 2)
	
	match rng_color:
		0:
			glow.light_color = SpellLibrary.rarity_color["Common"]
		1:
			glow.light_color = SpellLibrary.rarity_color["Uncommon"]
		2:
			glow.light_color = SpellLibrary.rarity_color["Rare"]

func grab_spell_icons():
	spell_icons = SpellLibrary.get_icon_list()
		
func generate_random_spell(rarity = "Random"):
	if rarity == "Random":
		spell = SpellLibrary.get_random_spell_up_to_tier("Rare")
	else:
		spell = SpellLibrary.get_random_spell_of_tier(rarity)

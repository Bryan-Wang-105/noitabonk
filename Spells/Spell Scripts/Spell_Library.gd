extends Node

var tieredSpells = {
	"Common": ["Fireball", "Developmental Sentry"],
	"Uncommon": ["Snowball", "Pickup Truck", "User-Acceptance-Testing Sentry"],
	"Rare": ["Planetary Devastation"]
}

var spellMappings = {
	"Fireball": {"path": "uid://cejcnawkav1q",
				 "icon": "uid://c0pm0vmoen1gu"
				},
	"Snowball": {"path": "uid://baf2rbt0kyx55",
				 "icon": "uid://b78qudd2h5dy0"
				},
	"Planetary Devastation": {
				"path": "uid://crlvykbdehka7",
				"icon": "uid://cdjim0p5p52sk"
				},
	"Pickup Truck": {
				"path": "uid://ci4djej1p31rs",
				"icon": "uid://dv2n8cm2gks55"
				},
	"Developmental Sentry": {
				 "path": "uid://caohlvg12shbt",
				 "icon": "uid://7o0cili8xiay"
				},
	"User-Acceptance-Testing Sentry": {
				 "path": "uid://bgwhgexcs5uyy",
				 "icon": "uid://b3bjkc8upu0fl"
				},
}

var tier_weights = {
	"Common": 60,
	"Uncommon": 75,
	"Rare": 90,
	"Legendary": 100
}

var rarity_color = {
	"Common" : Color.GRAY,
	"Uncommon": Color.WEB_GREEN,
	"Rare": Color.REBECCA_PURPLE
}

var inventory_spells = create_empty_inventory()

signal spell_inventory_changed()

func create_empty_inventory():
	var array = []
	
	for i in range(30):
		array.append(null)
	
	return array


func get_random_spell_of_tier(tier: String):
	print("GET RANDOM SPELL")
	print(tier)
	var spells_in_tier = tieredSpells[tier]
	
	if spells_in_tier.is_empty():
		return null
	
	var random_spell_name = spells_in_tier[randi() % spells_in_tier.size()]
	print("GENERATING SPELL " + random_spell_name)
	var spell_path = spellMappings[random_spell_name]["path"]
	
	return load(spell_path).new()

func get_random_spell_up_to_tier(tier):
	#print("TIER IS " + tier)
	var rng = randi_range(0, tier_weights[tier])
	rng += Global.playerManager.luck
	#print(rng)
	var spell
	
	if rng <= tier_weights["Common"]:
		spell = get_random_spell_of_tier("Common")
	elif rng <= tier_weights["Uncommon"]:
		spell = get_random_spell_of_tier("Uncommon")
	elif rng <= tier_weights["Rare"]:
		spell = get_random_spell_of_tier("Rare")
	elif rng <= tier_weights["Legendary"]:
		spell = get_random_spell_of_tier("Common")
	
	return spell

func add_spell_auto(spell):
	print("ADDING SPELL TO SPELL INVENTORY")
	for i in range(len(inventory_spells)):
		if not inventory_spells[i]:
			inventory_spells[i] = spell
			emit_signal("spell_inventory_changed")
			return true
	return false

func add_spell(indx, spell):
	inventory_spells[indx] = spell
	emit_signal("spell_inventory_changed")

func remove_spell(indx):
	inventory_spells[indx] = null
	emit_signal("spell_inventory_changed")
	
func get_icon_list():
	var res = []
	
	for spell in spellMappings:
		var uid = str(spellMappings[spell]["icon"])
		res.append(uid)
	
	return res

# WandData.gd

# Used to generate wands / get info from wands
extends Resource
class_name WandData

# Wand Tiered Stats
const TIER_STATS = {
	0: {
		"rarity": "Common",
		"dmg_mult": [1.0, 1.15],
		"cast_delay": [0.15, .35],
		"reload_speed": [.7, 1.3],
		"capacity": [6, 10],
		"spread": [.1, .2]
	},
	1: {
		"rarity": "Uncommon",
		"dmg_mult": [1.15, 1.4],
		"cast_delay": [0.1, .25],
		"reload_speed": [.3, .5],
		"capacity": [3, 7],
		"spread": [.07, .13]
	},
	2: {
		"rarity": "Rare",
		"dmg_mult": [1.4, 2],
		"cast_delay": [0.03, .1],
		"reload_speed": [.1, .3],
		"capacity": [5, 12],
		"spread": [0, 0.07]
	}
}

# Wand stats
@export var rarity: String = "NA"
@export var dmg_mult: float = 1.0
@export var cast_delay: float = 0.1
@export var reload_speed: float = 1.0
@export var spread: float = 0
@export var capacity: int = 1

# Spells in this wand (can contain nulls for empty slots)
var spells = []

func _init(level: int = 0):
	print("LEVEL")
	print(level)
	var stats = TIER_STATS.get(level)
	
	rarity = stats.rarity
	dmg_mult = round(randf_range(stats.dmg_mult[0], stats.dmg_mult[1]) * 100) / 100
	cast_delay = round(randf_range(stats.cast_delay[0], stats.cast_delay[1]) * 100 ) / 100
	reload_speed = round(randf_range(stats.reload_speed[0], stats.reload_speed[1]) * 100 ) / 100
	spread = round(randf_range(stats.spread[0], stats.spread[1]) * 100 ) / 100
	capacity = round(randi_range(stats.capacity[0], stats.capacity[1]) * 100 ) / 100

	# Initialize empty spell array
	spells.resize(capacity)
	
	fill_spells()
	
#
func fill_spells():
	## Add guaranteed spell matching wand rarity in first slot
	var guaranteed_spell = SpellLibrary.get_random_spell_of_tier(rarity)
	if guaranteed_spell:
		add_spell(guaranteed_spell)
	
	## Generate random number of additional spells for remaining slots
	var remaining_slots = capacity - 1
	var num_additional_spells = randi() % (remaining_slots + 1)  # 0 to remaining_slots
	#
	## Fill remaining slots with random spells up to wand's tier
	for i in range(num_additional_spells):
		var random_spell = SpellLibrary.get_random_spell_up_to_tier(rarity)
		if random_spell:
			add_spell(random_spell)
#
## Helper to add a spell to the next available slot
func add_spell(spell: Spell) -> bool:
	for i in range(spells.size()):
		if spells[i] == null:
			spells[i] = spell
			return true
	
	print("Wand is full")
	return false  # No empty slots

# Helper to get spell at index (returns null if out of bounds)
func get_spell(index: int):
	if index >= 0 and index < spells.size():
		return spells[index]
	return null

# Check if wand has any spells
func has_spells() -> bool:
	for spell in spells:
		if spell != null:
			return true
	return false

func get_stats():
	return [dmg_mult, cast_delay, reload_speed, spread, capacity, rarity, spells]

func print_wand_stats():
	print("=== Wand Stats ===")
	print("Rarity: " + rarity)
	print("Damage Mult:   %.2f" % dmg_mult)
	print("Cast Delay:    %.2fs" % cast_delay)
	print("Reload Speed:  %.2fs" % reload_speed)
	print("Spread:        %.1f°" % spread)
	print("Capacity:      %d" % capacity)
	print("==================")

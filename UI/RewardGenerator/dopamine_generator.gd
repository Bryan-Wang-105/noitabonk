extends Node

var tier_weights = {
	"BaseStat": 65,
	"Spell": 90, #25%
	"Wand": 95,  #5%
	"Perk": 100  #5%
}

var base_stats = [
	"max_health",
	"hp_regen",
	"enhanced_xp_gain",
	"enhanced_hp_gain",
	# Movement stats
	"walk_speed",
	"sprint_speed",
	"jump_height",
	# Crit stats
	"critical_strike_chance",
	"critical_strike_dmg",
	# Misc stats
	"life_steal",
	"luck",
	"enhanced_gold_gain",
    "pickup_range"
]

func _ready():
	Global.rewardGenerator = self

func generate_rewards():
	var rewards = []
	var stats_generated = []
	var spells_generated = []
	
	for i in range(3):
		var rng = randi_range(0, 94)
		
		if rng < tier_weights["BaseStat"]:
			print("adding stat to rewards")
			
			var new_stat = generate_stat()
			
			# Keep generating until we get a unique stat
			while new_stat[0][0] in stats_generated:
				print("PREVENTED DUPLICATE STAT\n\n\n\n")
				new_stat = generate_stat()
			
			rewards.append(new_stat)
			stats_generated.append(new_stat[0][0])
		
		elif rng < tier_weights["Spell"]:
			print("adding spell to rewards")
			
			var new_spell = generate_spell()
			
			# Keep generating until we get a unique stat
			while new_spell in spells_generated:
				print("PREVENTED DUPLICATE SPELL\n\n\n\n")
				new_spell = generate_stat()
			
			rewards.append(new_spell)
			spells_generated.append(new_spell)
			
		elif rng < tier_weights["Wand"]:
			print("adding wand to rewards")
			rewards.append(generate_wand())
		else:
			print("PERK GENERATED")
			
	print(rewards)
	return rewards

func generate_spell():
	var spell
	var tier = 1
	var rng = randi_range(0, 100)
	rng += Global.playerManager.luck
	
	if rng > 90:
		spell = SpellLibrary.get_random_spell_of_tier("Rare")
		tier = 3
	elif rng > 60:
		spell = SpellLibrary.get_random_spell_of_tier("Uncommon")
		tier = 2
	else:
		spell = SpellLibrary.get_random_spell_of_tier("Common")
		tier = 1
	
	print("SPELL ADDED")
	print(tier)
	print(spell.name)
	return [spell, tier]


func generate_stat():
	var tier = 1
	var rng = randi_range(0, len(base_stats) - 1)
	print(base_stats[rng])
	
	var curr_stat_amt = Global.playerManager.return_stat(base_stats[rng])
	var upgrade_amt
	
	var rng2 = randi_range(0, 100) + int(Global.playerManager.luck)
	print("STAT GENERATED RNG2: ", rng2)

	# If curr stat is at 0
	if curr_stat_amt == 0:
		# Base 3% value if starting from zero
		upgrade_amt = .03

	# If it's a percentage based stat like crit, luck, lifesteal etc
	# start at 5% increase up to potentially 
	if curr_stat_amt < 1:
		upgrade_amt = .05
		# Still allow RNG-based boosts
		if rng2 > 90:
			upgrade_amt *= 2.5
			tier = 3
		elif rng2 > 80:
			upgrade_amt *= 1.5 # ~10%
			tier = 2
			
	else:
		# Base 5% upgrade from current amount
		upgrade_amt = curr_stat_amt * 0.05

		# RNG boosts on top of that
		if rng2 > 90:
			upgrade_amt = curr_stat_amt * 0.15
			tier = 3
		elif rng2 > 80:
			upgrade_amt = curr_stat_amt * 0.10
			tier = 2
	
	print("GENERATED STAT OF RARITY TIER")
	print(tier)
	
	return [[base_stats[rng], curr_stat_amt, snapped(upgrade_amt, 0.01)], tier]
	
func generate_wand():
	var wand
	var tier = 1
	var rng = randi_range(0, 100)
	rng += Global.playerManager.luck
	
	print("ADDING WAND")
	if rng > 90:
		wand = WandData.new(2, true)
		tier = 3
	elif rng > 60:
		wand = WandData.new(1, true)
		tier = 2
	else:
		wand = WandData.new(0, true)
	
	print("WAND ADDED")
	print(wand)
	return [wand, tier]

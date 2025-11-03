extends Node

var tier_weights = {
	"BaseStat": 65,
	"Spell": 85, #20%
	"Wand": 95,  #10%
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
	"gold_gain",
    "pickup_range"
]

func _ready():
	Global.rewardGenerator = self

func generate_rewards():
	
	var rewards = []
	
	for i in range(3):
		var rng = randi_range(0, 94)
		
		if rng < tier_weights["BaseStat"]:
			print("adding stat to rewards")
			rewards.append(generate_stat())
		elif rng < tier_weights["Spell"]:
			print("adding spell to rewards")
			rewards.append(SpellLibrary.get_random_spell_up_to_tier("Rare"))
		elif rng < tier_weights["Wand"]:
			print("adding wand to rewards")
			rewards.append(generate_wand())
		else:
			print("PERK GENERATED")
			
	print(rewards)
	return rewards

func generate_stat():
	var rng = randi_range(0, len(base_stats) - 1)
	print(base_stats[rng])
	
	var curr_stat_amt = Global.playerManager.return_stat(base_stats[rng])
	var upgrade_amt
	
	if curr_stat_amt == 0:
		upgrade_amt = 3
	else:
		upgrade_amt = curr_stat_amt * .03
	
	var rng2 = randi_range(0, 10)
	
	if rng2 > 9:
		upgrade_amt *= 2
	elif rng > 6:
		upgrade_amt *= 1.5
	elif rng > 4:
		upgrade_amt *= 1.33
	
	return [base_stats[rng], curr_stat_amt, upgrade_amt]
	
func generate_wand():
	var wand
	var rng = randi_range(0, 10)
	
	if rng > 9:
		wand = WandData.new(2)
	elif rng > 6:
		wand = WandData.new(1)
	elif rng > 4:
		wand = WandData.new(0)
	
	return wand

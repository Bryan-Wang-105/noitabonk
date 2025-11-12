extends Node
class_name PlayerStats

# EXP STATS
var curr_level: int = 1
var curr_xp: int = 0
var next_xp_req: int = 100
var enemies_slain = 0
@export var enhanced_xp_gain: float = 0.0

const BASE_XP: int = 100
const MULTIPLIER: float = 1.5  # 50% increase per level

# HEALTH STATS
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var hp_regen: float = 0.0
@export var enhanced_hp_gain: float = 0.0

# MVMT STATS
@export var walk_speed: float = 6.0
@export var sprint_speed: float = 8.0
@export var jump_height: float = 4.5

# CRIT STATS
@export var critical_strike_chance: float = 0.0  # 5%
@export var critical_strike_dmg: float = 30  # 30% dmg

# MISC STATS
@export var life_steal: float = 0.0
@export var luck: float = 0.0
@export var gold: int = 10
@export var enhanced_gold_gain: float = 0.0
@export var pickup_range: float = .5
@export var reroll_amt: int = 5


# Signals for UI updates
signal health_changed(new_health, max_health)
signal level_changed(new_level)
signal experience_changed(new_exp)
signal gold_changed(new_gold)
signal slain_count_changed(new_amt)
signal stats_changed

func _ready():
	Global.playerManager = self
	
	next_xp_req = calculate_xp_for_level(curr_level + 1)

# Movement setters
func set_walk_speed(value: float) -> void:
	
	print("OLD WALK SPEED: ")
	print(walk_speed)
	walk_speed = max(0.0, value)
	
	print("NEW WALK SPEED: ")
	print(walk_speed)

func set_run_speed(value: float) -> void:
	print("OLD sprint_speed: ")
	print(sprint_speed)
	sprint_speed = max(0.0, value)
	
	print("NEW sprint_speed: ")
	print(sprint_speed)

func set_jump_height(value: float) -> void:
	print("OLD jump_height: ")
	print(jump_height)
	jump_height = max(0.0, value)
	
	print("NEW jump_height: ")
	print(jump_height)


# Health setters
func set_health(value: float) -> void:
	# Add more HP
	print("HP GAIN IS: ")
	value *= (1 + (enhanced_hp_gain / 100)) 
	print(value)
	
	health = clamp(value, 0.0, max_health)
	health_changed.emit(health, max_health)

func set_max_health(value: float) -> void:
	print("OLD max_health: ")
	print(max_health)
	
	
	# Add more HP
	print("HP GAIN IS: ")
	value *= (1 + (enhanced_hp_gain / 100)) 
	print(value)
	
	max_health = max(1.0, value)
	
	print("NEW max_health: ")
	print(max_health)
	
	health = min(health, max_health)  # Adjust current health if needed
	health_changed.emit(health, max_health)

func add_health(amount: float) -> void:
	set_health(health + amount)

func take_damage(amount: float) -> void:
	set_health(health - amount)
	health_changed.emit(health, max_health)

# Calculate XP required to reach a specific level
func calculate_xp_for_level(level: int) -> int:
	if level <= 1:
		return 0
	
	var xp = BASE_XP * pow(MULTIPLIER, level - 2)
	return round_to_nearest(xp, 5)  # Round to nearest 5

# Round to nearest increment (5, 10, etc.)
func round_to_nearest(value: float, increment: int) -> int:
	return int(round(value / increment) * increment)

# Add XP and handle level ups
func add_xp(amount: int):
	curr_xp += amount
	
	experience_changed.emit(amount)
	
	# Check for level up(s)
	while curr_xp >= next_xp_req:
		level_up()

# Add # of enemies slain
func add_slain(amount: int):
	enemies_slain += amount
	
	slain_count_changed.emit(amount)


func level_up():
	curr_xp -= next_xp_req  # Carry over excess XP
	curr_level += 1
	next_xp_req = calculate_xp_for_level(curr_level + 1)
	
	print("Level Up! Now level ", curr_level)
	print("XP: ", curr_xp, "/", next_xp_req)
	
	experience_changed.emit()
	
	# Emit signal or trigger level up effects here
	level_changed.emit(curr_level)
	Global.audio_node.play_lvl_up_fx()
	
# Get total XP earned across all levels
func get_total_xp() -> int:
	var total = curr_xp
	for level in range(2, curr_level + 1):
		total += calculate_xp_for_level(level)
	return total

# Get progress as percentage (for UI bars)
func get_xp_progress() -> float:
	return float(curr_xp) / float(next_xp_req)


# Gold setters
func set_gold(value: int) -> void:
	gold = max(0, value)
	gold_changed.emit()

func add_gold(amount: int) -> void:
	set_gold(gold + amount)
	gold_changed.emit(amount)

func remove_gold(amount: int) -> bool:
	if gold >= amount:
		set_gold(gold - amount)
		return true
	return false

func set_enhanced_gold_gain(amount):
	enhanced_gold_gain = amount

func set_pickup_range(amount: float):
	print("OLD PICK UP RANGE: ")
	print(Global.player.pick_up_collider.shape.radius)
	pickup_range = amount
	Global.player.pick_up_collider.shape.radius = amount
	print("NEW RANGE:")
	print(Global.player.pick_up_collider.shape.radius)

# Combat stat setters
func set_critical_strike_chance(value: float) -> void:
	print("OLD CRIT: ")
	print(critical_strike_chance)
	critical_strike_chance = clamp(value, 0, 100)  # Keep between 0-100%
	print("NEW CRIT: ")
	print(critical_strike_chance)

func set_critical_strike_dmg(value: float) -> void:
	print("OLD CRIT DMG: ")
	print(critical_strike_dmg)
	critical_strike_dmg = max(1.0, value)
	print("NEW CRIT DMG: ")
	print(critical_strike_dmg)

func set_luck(value: float) -> void:
	print("OLD LUCK: ")
	print(luck)
	
	luck = max(0.0, value)
	
	print("NEW LUCK: ")
	print(luck)

# Utility function to check if attack is critical
func is_critical_hit() -> bool:
	return randf() < critical_strike_chance

func return_stat(stat_name: String):
	match stat_name:
		# XP STATS
		"enhanced_xp_gain":
			return enhanced_xp_gain

		# HEALTH STATS
		"max_health":
			return max_health
		"hp_regen":
			return hp_regen
		"enhanced_hp_gain":
			return enhanced_hp_gain

		# MOVEMENT STATS
		"walk_speed":
			return walk_speed
		"sprint_speed":
			return sprint_speed
		"jump_height":
			return jump_height

		# CRIT STATS
		"critical_strike_chance":
			return critical_strike_chance
		"critical_strike_dmg":
			return critical_strike_dmg

		# MISC STATS
		"life_steal":
			return life_steal
		"luck":
			return luck
		"enhanced_gold_gain":
			return enhanced_gold_gain
		"pickup_range":
			return pickup_range
	

func upgrade_stat(load):
	print(load)
	var stat_name = load[0]
	var increase_amount = load[2]
	
	# Check if property exists
	if stat_name in self:
		var current_value = get(stat_name)
		var new_value = current_value + increase_amount
		
		# Use setter if it exists, otherwise set directly
		match stat_name:
			"max_health":
				set_max_health(new_value)
			"walk_speed":
				set_walk_speed(new_value)
			"sprint_speed":
				set_run_speed(new_value)
			"jump_height":
				set_jump_height(new_value)
			"pickup_range":
				set_pickup_range(new_value)
			"enhanced_gold_gain":
				set_enhanced_gold_gain(new_value)
			"critical_strike_chance":
				set_critical_strike_chance(new_value)
			"critical_strike_dmg":
				set_critical_strike_dmg(new_value)
			"luck":
				set_luck(new_value)
			_:
				set(stat_name, new_value)
		
		print("Upgraded %s: %s -> %s (+%s)" % [stat_name, current_value, new_value, increase_amount])
		
		stats_changed.emit()
	
	else:
		push_warning("Unknown stat: " + stat_name)

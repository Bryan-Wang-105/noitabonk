extends Node
class_name PlayerStats

# Movement stats
@export var walk_speed: float = 6.0
@export var sprint_speed: float = 8.0
@export var jump_height: float = 4.5

# Core stats
@export var health: float = 100.0
@export var max_health: float = 100.0

var curr_level: int = 1
var curr_xp: int = 0
var next_xp_req: int = 100

const BASE_XP: int = 100
const MULTIPLIER: float = 1.5  # 50% increase per level

@export var gold: int = 0

# Combat stats
@export var critical_strike_chance: float = 0.05  # 5%
@export var critical_strike_dmg: float = 2.0  # 2x damage multiplier
@export var luck: float = 1.0

# Signals for UI updates
signal health_changed(new_health, max_health)
signal level_changed(new_level)
signal experience_changed(new_exp)
signal gold_changed(new_gold)

func _ready():
	Global.playerManager = self
	
	next_xp_req = calculate_xp_for_level(curr_level + 1)

# Movement setters
func set_walk_speed(value: float) -> void:
	walk_speed = max(0.0, value)

func set_run_speed(value: float) -> void:
	sprint_speed = max(0.0, value)

func set_jump_height(value: float) -> void:
	jump_height = max(0.0, value)

# Health setters
func set_health(value: float) -> void:
	health = clamp(value, 0.0, max_health)
	health_changed.emit(health, max_health)

func set_max_health(value: float) -> void:
	max_health = max(1.0, value)
	health = min(health, max_health)  # Adjust current health if needed
	health_changed.emit(health, max_health)

func add_health(amount: float) -> void:
	set_health(health + amount)

func take_damage(amount: float) -> void:
	set_health(health - amount)

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

# Combat stat setters
func set_critical_strike_chance(value: float) -> void:
	critical_strike_chance = clamp(value, 0.0, 1.0)  # Keep between 0-100%

func set_critical_strike_dmg(value: float) -> void:
	critical_strike_dmg = max(1.0, value)

func set_luck(value: float) -> void:
	luck = max(0.0, value)

# Utility function to check if attack is critical
func is_critical_hit() -> bool:
	return randf() < critical_strike_chance

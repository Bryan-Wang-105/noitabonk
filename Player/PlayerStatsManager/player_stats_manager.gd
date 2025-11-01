extends Node
class_name PlayerStats

# Movement stats
@export var walk_speed: float = 5.0
@export var run_speed: float = 10.0
@export var jump_height: float = 5.0

# Core stats
@export var health: float = 100.0
@export var max_health: float = 100.0
@export var level: int = 1
@export var experience: int = 0
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

# Movement setters
func set_walk_speed(value: float) -> void:
	walk_speed = max(0.0, value)

func set_run_speed(value: float) -> void:
	run_speed = max(0.0, value)

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

# Level and experience setters
func set_level(value: int) -> void:
	level = max(1, value)
	level_changed.emit(level)

func set_experience(value: int) -> void:
	experience = max(0, value)
	experience_changed.emit(experience)

func add_experience(amount: int) -> void:
	set_experience(experience + amount)

# Gold setters
func set_gold(value: int) -> void:
	gold = max(0, value)
	gold_changed.emit(gold)

func add_gold(amount: int) -> void:
	set_gold(gold + amount)

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

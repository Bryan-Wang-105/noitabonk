# enemy_manager.gd
extends Node

# Enemy Spawn configurations
@export var spawn: bool = false
@export var frozen: bool
var spawning = false

# Vars
var start = false
@onready var world: Node3D = $".."
@onready var spawn_points: Node3D = $"../SpawnPoints"

# Spawning Manager Vars
@export var spawn_interval: float = 1.0  # seconds between spawn checks
@export var base_credit_gain: float = 1.0
@export var difficulty_scale: float = 0.05  # how fast difficulty increases
@export var max_difficulty: float = 10.0
var spawn_credit: float = 0.0
var difficulty: float = 1.0
var time_alive: float = 0.0
var timestamp = ""
var elapsed_time = 0.0

var enemy_costs = {
	"weak": 5.0,
	"med": 6.0,
	"strong": 15.0
}

var enemies = []

var enemy_list = {
	"weak": ["uid://q4y1siqkv8x7", "uid://dt7o63tgencf8", "uid://d1s37xh70tlr2"], # Wizard / Duck / OrcKnight
	"med": ["uid://chruqu6gxfks"], 						   # Orc
	"strong": ["uid://blhjw6c6bhkil"]					   # BigBoy
}

#@export var enemy_weak: PackedScene
#@export var enemy_med: PackedScene
#@export var enemy_strong: PackedScene
var enemy_weak
var enemy_med
var enemy_strong

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Global.enemy_manager = self
	process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if spawn:
		_spawn_loop()

func _spawn_loop():
	if not spawn:
		return
	
	spawning = true
	
	while true and not Global.paused:
		await get_tree().create_timer(spawn_interval).timeout
		_update_difficulty()
		_gain_credits()
		_attempt_spawn()
		
	spawning = false


func _update_difficulty():
	time_alive += spawn_interval
	difficulty = min(1.0 + time_alive * difficulty_scale, max_difficulty)
	format_time(elapsed_time)
	print(timestamp, ": Updating difficulty to ", difficulty)

func _gain_credits():
	spawn_credit += base_credit_gain * difficulty

func _attempt_spawn():
	if spawn_credit < enemy_costs["weak"]:
		return

	# 1. Pick what to spawn based on difficulty
	var possible_spawns = []
	if difficulty < 3:
		enemy_weak = enemy_list["weak"][randi_range(0, len(enemy_list["weak"]) - 1)]
		enemy_med = enemy_list["med"][randi_range(0, len(enemy_list["med"]) - 1)]
		
		possible_spawns = [{"scene": enemy_weak, "cost": enemy_costs["weak"]},
						   {"scene": enemy_med, "cost": enemy_costs["med"]}]
	else:
		enemy_weak = enemy_list["weak"][randi_range(0, len(enemy_list["weak"]) - 1)]
		enemy_med = enemy_list["med"][randi_range(0, len(enemy_list["med"]) - 1)]
		enemy_strong = enemy_list["strong"][randi_range(0, len(enemy_list["strong"]) - 1)]
		
		possible_spawns = [
			{"scene": enemy_weak, "cost": enemy_costs["weak"]},
			{"scene": enemy_med, "cost": enemy_costs["med"]},
			{"scene": enemy_strong, "cost": enemy_costs["strong"]}
		]

	# 2. Pick random option
	# Getting random elgible choice
	var choice = possible_spawns[randi() % possible_spawns.size()]
	if spawn_credit >= choice["cost"]:
		format_time(elapsed_time)
		if choice["cost"] == enemy_costs["weak"]:
			print(timestamp, ": Spawning WEAK Enemy Now! Difficulty: ", difficulty)
		elif choice["cost"] == enemy_costs["med"]:
			print(timestamp, ": Spawning MED Enemy Now! Difficulty: ", difficulty)
		else:
			print(timestamp, ": Spawning STRONG Enemy Now! Difficulty: ", difficulty)
			
		_spawn_enemy(choice["scene"])
		spawn_credit -= choice["cost"]

func _spawn_enemy(enemy_uid):
	if not start:
		start = true

	if not enemy_uid or spawn_points.get_child_count() == 0:
		return

	var spawn_point = spawn_points.get_children().pick_random()
	var enemy = load(enemy_uid).instantiate()
	world.add_child(enemy)
	enemies.append(enemy)
	enemy.global_position = spawn_point.global_position

#func spawn_enemies():
	#for i in range(enemy_count):
		## Random angles for spherical coordinates
		#var theta = randf_range(0.0, TAU)  # Horizontal angle (0 to 2π)
		#var phi = randf_range(0.0, PI / 2.0)  # Vertical angle (0 to π/2 for upper hemisphere only)
		#
		## Convert spherical to Cartesian coordinates
		#var radius = 10.0
		#var offset = Vector3(
			#radius * sin(phi) * cos(theta),  # X
			#radius * cos(phi),                # Y
			#radius * sin(phi) * sin(theta)   # Z
		#)
		#
		#var spawn_position = Global.player.global_position + offset
		#
		## Ensure y is never below 0
		#spawn_position.y = max(1, 0.0)
		#
		## Create and position enemy
		#var enemy = enemyScene.instantiate()
		#enemy.position = spawn_position
		#world.add_child(enemy)
		#enemies.append(enemy)
		#
		#start_spawn()

func start_spawn():
	start = true

func _process(delta):
	if not spawning:
		_spawn_loop()

	elapsed_time += delta
	
	if start:
		# Single loop processing all enemies
		for enemy in enemies:
			if enemy and not frozen:
				update_enemy(enemy, delta)

func format_time(seconds: float):
	var hours = int(seconds) / 3600
	var minutes = (int(seconds) % 3600) / 60
	var secs = int(seconds) % 60
	
	timestamp = "%02d:%02d:%02d" % [hours, minutes, secs]

func update_enemy(enemy, delta: float):
	if !enemy.alive:
		print("ENEMY IS DEAD 2")
		Global.playerManager.add_slain(1)
		enemies.erase(enemy)  # Remove from array
		enemy.die()     # Delete the node
	
	
	# Apply gravity
	# Climbing logic
	if enemy.ray and enemy.ray.is_colliding() and !enemy.being_pulled:
		enemy.velocity.y = enemy.speed  # Climb up at same speed as horizontal movement
	elif not enemy.is_on_floor():
		enemy.velocity.y -= gravity * delta  # Apply gravity when in air
	else:
		enemy.velocity.y = 0.0  # On ground
	
	# Horizontal movement toward player
	var direction = (Global.player.global_position - enemy.global_position).normalized()
	direction.y = 0.0  # Keep movement horizontal only
	
	# Make enemy face the direction (instant)
	if direction.length() > 0.01:
		enemy.rotation.y = atan2(-direction.x, -direction.z)
	
	if enemy.being_pulled:
		pass
	else:
		enemy.velocity.x = direction.x * enemy.speed
		enemy.velocity.z = direction.z * enemy.speed
	
	# Apply movement
	enemy.move_and_slide()
	
	if abs((enemy.global_position - Global.player.global_position)).length() < enemy.attack_radius:
		enemy.attack_player()

func add_enemy(enemy):
	enemies.append(enemy)

func remove_enemy(enemy):
	enemies.erase(enemy)
	enemy.queue_free()

# enemy_manager.gd
extends Node

@export var enemy_count: int
@export var frozen: bool
@onready var world: Node3D = $".."
@onready var spawn_points: Node3D = $"../SpawnPoints"

@export var enemy_weak: PackedScene
@export var enemy_strong: PackedScene
@export var spawn_interval: float = 1.0  # seconds between spawn checks
@export var base_credit_gain: float = 1.0
@export var difficulty_scale: float = 0.05  # how fast difficulty increases
@export var max_difficulty: float = 10.0

var spawn_credit: float = 0.0
var difficulty: float = 1.0
var time_alive: float = 0.0
var timestamp = ""
var elapsed_time = 0.0
var spawning = false

var enemy_costs = {
	"weak": 5.0,
	"strong": 15.0
}

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var enemies = []
var start = false

func _ready():
	Global.enemy_manager = self
	process_mode = Node.PROCESS_MODE_PAUSABLE
	_spawn_loop()

func _spawn_loop():
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
		possible_spawns = [{"scene": enemy_weak, "cost": enemy_costs["weak"]}]
	else:
		possible_spawns = [
			{"scene": enemy_weak, "cost": enemy_costs["weak"]},
			{"scene": enemy_strong, "cost": enemy_costs["strong"]}
		]

	# 2. Pick random option
	var choice = possible_spawns[randi() % possible_spawns.size()]
	if spawn_credit >= choice["cost"]:
		format_time(elapsed_time)
		if choice["scene"] == enemy_weak:
			print(timestamp, ": Spawning WEAK Enemy Now! Difficulty: ", difficulty)
		else:
			print(timestamp, ": Spawning STRONG Enemy Now! Difficulty: ", difficulty)
			
		_spawn_enemy(choice["scene"])
		spawn_credit -= choice["cost"]

func _spawn_enemy(enemy_scene: PackedScene):
	if not start:
		start = true

	if not enemy_scene or spawn_points.get_child_count() == 0:
		return

	var spawn_point = spawn_points.get_children().pick_random()
	var enemy = enemy_scene.instantiate()
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
	if enemy.is_on_wall() and !enemy.being_pulled:
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

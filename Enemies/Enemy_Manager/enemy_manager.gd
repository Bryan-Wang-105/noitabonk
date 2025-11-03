# enemy_manager.gd
extends Node

@export var enemy_count: int
@export var enemyScene: PackedScene

@onready var world: Node3D = $".."

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var enemies = []
var start = false

func spawn_enemies():
	for i in range(enemy_count):
		# Random angles for spherical coordinates
		var theta = randf_range(0.0, TAU)  # Horizontal angle (0 to 2π)
		var phi = randf_range(0.0, PI / 2.0)  # Vertical angle (0 to π/2 for upper hemisphere only)
		
		# Convert spherical to Cartesian coordinates
		var radius = 10.0
		var offset = Vector3(
			radius * sin(phi) * cos(theta),  # X
			radius * cos(phi),                # Y
			radius * sin(phi) * sin(theta)   # Z
		)
		
		var spawn_position = Global.player.global_position + offset
		
		# Ensure y is never below 0
		spawn_position.y = max(1, 0.0)
		
		# Create and position enemy
		var enemy = enemyScene.instantiate()
		enemy.position = spawn_position
		world.add_child(enemy)
		enemies.append(enemy)
		
		start_spawn()

func start_spawn():
	start = true

func _process(delta):
	if start:
		# Single loop processing all enemies
		for enemy in enemies:
			if enemy:
				update_enemy(enemy, delta)

func update_enemy(enemy, delta: float):
	if !enemy.alive:
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

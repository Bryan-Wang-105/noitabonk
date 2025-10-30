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
	if not enemy.is_on_floor():
		enemy.velocity.y -= gravity * delta
	else:
		enemy.velocity.y = 0.0  # Reset vertical velocity when on ground
	
	# Horizontal movement toward player
	var direction = (Global.player.global_position - enemy.global_position).normalized()
	direction.y = 0.0  # Keep movement horizontal only
	
		# Make enemy face the direction (instant)
	if direction.length() > 0.01:
		enemy.rotation.y = atan2(-direction.x, -direction.z)
	
	enemy.velocity.x = direction.x * enemy.speed
	enemy.velocity.z = direction.z * enemy.speed
	
	# Apply movement
	enemy.move_and_slide()
	
	# Health checks, etc.
	if enemy.health <= 0:
		remove_enemy(enemy)

func add_enemy(enemy):
	enemies.append(enemy)

func remove_enemy(enemy):
	enemies.erase(enemy)
	enemy.queue_free()




#extends Node3D
#
#@export var enemy_scene: PackedScene
#@onready var player: CharacterBody3D = $"../Player"
#
#@export var ground_ray_height := 2.0
#@export var ground_ray_depth := 10.0
#@export var enemy_count: int
#@export var spawn_radius := 50.0
#@export var gravity := 30.0
#@export var move_speed := 5.0
#@export var enemy_radius := .5  # used for avoidance
#
#var enemies: Array[Node3D] = []
#var velocities: Array[Vector3] = []  # one velocity per enemy
#
#func _ready():
	#pass
	##spawn_enemies()
#
#func spawn_enemies():
	#for i in range(enemy_count):
		#var e = enemy_scene.instantiate()
		#var angle = randf() * TAU
		#var dist = randf_range(10, spawn_radius)
		#e.position = player.position + Vector3(cos(angle) * dist, 0, sin(angle) * dist)
		#add_child(e)
		#enemies.append(e)
		#velocities.append(Vector3.ZERO)
#
#func _physics_process(delta):
	#var space := get_world_3d().direct_space_state
	#var ray_query := PhysicsRayQueryParameters3D.create(Vector3.ZERO, Vector3.ZERO)
	#var player_pos = player.global_position
#
	#for i in range(enemies.size()):
		#var e = enemies[i]
		#var vel = velocities[i]
#
		## ------------------------------------------------------------
		## 1. Gravity
		## ------------------------------------------------------------
		#vel.y -= gravity * delta
#
		## ------------------------------------------------------------
		## 2. Move toward player
		## ------------------------------------------------------------
		#var to_player = player_pos - e.global_position
		#to_player.y = 0
		#if to_player.length_squared() > 4:
			#to_player = to_player.normalized()
			#vel.x = move_toward(vel.x, to_player.x * move_speed, move_speed * delta)
			#vel.z = move_toward(vel.z, to_player.z * move_speed, move_speed * delta)
#
		## ------------------------------------------------------------
		## 3. Basic avoidance (enemies + player)
		## ------------------------------------------------------------
		#for j in range(enemies.size()):
			#if i == j:
				#continue
#
			#var other = enemies[j]
			#var offset = e.global_position - other.global_position
			#var dist_sq = offset.length_squared()
			#var min_dist = enemy_radius * 2.0
#
			#if dist_sq < min_dist * min_dist and dist_sq > 0.0001:
				#var dist = sqrt(dist_sq)
				#var penetration = min_dist - dist
				#var push_dir = offset.normalized()
#
				## Push both enemies apart equally
				#e.global_position += push_dir * (penetration * 0.5)
				#other.global_position -= push_dir * (penetration * 0.5)
#
				## Add a small velocity nudge for stability
				#vel += push_dir * penetration * 2.0 * delta
#
		## Avoid player collision
		#var to_player_flat = e.global_position - player_pos
		#to_player_flat.y = 0
		#if to_player_flat.length_squared() < (enemy_radius * 2.0) ** 2:
			#vel += to_player_flat.normalized() * 4.0 * delta
#
		## ------------------------------------------------------------
		## 4. Apply movement
		## ------------------------------------------------------------
		#e.global_position += vel * delta
#
		## ------------------------------------------------------------
		## 5. Keep on ground (raycast)
		## ------------------------------------------------------------
		#var from = e.global_position + Vector3.UP * ground_ray_height
		#var to = e.global_position + Vector3.DOWN * ground_ray_depth
		#ray_query.from = from
		#ray_query.to = to
#
		#var hit = space.intersect_ray(ray_query)
		#if hit and hit.has("position"):
			#if e.global_position.y < hit.position.y + 0.2:
				#e.global_position.y = hit.position.y
				#vel.y = 0.0
#
		## Save velocity back
		#velocities[i] = vel

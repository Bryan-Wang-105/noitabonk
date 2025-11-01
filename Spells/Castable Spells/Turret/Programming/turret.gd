extends RigidBody3D

@onready var top_half: Node3D = $TopTurretMesh
@onready var area: Area3D = $Area3D

var dmg
var enemies_in_range: Array = []
var current_target: Node3D = null
var rotation_speed: float = 5.0  # Radians per second
var fire_rate: float = 0.5  # Seconds between shots
var time_since_last_shot: float = 0.0

func _ready():
	# Connect area signals
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	activate_timer()
	pass

func activate_timer() -> void:
	await get_tree().create_timer(10.0).timeout

	queue_free()

func _process(delta):
	# Update fire timer
	time_since_last_shot += delta
	
	# Update target
	_update_target()
	
	# Rotate towards target
	if current_target:
		_rotate_towards_target(delta)
		
		# Fire at target if enough time has passed
		if time_since_last_shot >= fire_rate:
			_fire()
			time_since_last_shot = 0.0

func _on_body_entered(body):
	# Check if the body is an enemy (adjust this condition based on your game)
	if body.is_in_group("enemies"):
		enemies_in_range.append(body)

func _on_body_exited(body):
	# Remove enemy from tracking
	if body in enemies_in_range:
		enemies_in_range.erase(body)
	
	# Clear target if it left the area
	if body == current_target:
		current_target = null

func _update_target():
	# Remove any invalid enemies (destroyed, freed, etc.)
	enemies_in_range = enemies_in_range.filter(func(enemy): return is_instance_valid(enemy))
	
	# If no enemies, clear target
	if enemies_in_range.is_empty():
		current_target = null
		return
	
	# Find nearest enemy
	var nearest_enemy = null
	var nearest_distance = INF
	
	for enemy in enemies_in_range:
		var distance = global_position.distance_to(enemy.global_position)
		if distance < nearest_distance:
			nearest_distance = distance
			nearest_enemy = enemy
	
	current_target = nearest_enemy

func _rotate_towards_target(delta):
	if not current_target:
		return
	
	# Get direction to target (only on XZ plane for turret rotation)
	var target_position = current_target.global_position
	var direction = Vector3(
		target_position.x - global_position.x,
		0,  # Keep Y at 0 for horizontal rotation only
		target_position.z - global_position.z
	).normalized()
	
	# Calculate target angle (turret faces -Z by default)
	var target_angle = atan2(direction.x, -direction.z)
	
	# Get current angle
	var current_angle = top_half.rotation.y
	
	# Smoothly rotate towards target
	var angle_diff = _angle_difference(current_angle, target_angle)
	var rotation_step = rotation_speed * delta
	
	if abs(angle_diff) < rotation_step:
		top_half.rotation.y = target_angle
	else:
		top_half.rotation.y += sign(angle_diff) * rotation_step

func _angle_difference(from_angle: float, to_angle: float) -> float:
	# Get the shortest angle difference (handling wraparound)
	var diff = fmod(to_angle - from_angle, TAU)
	if diff > PI:
		diff -= TAU
	elif diff < -PI:
		diff += TAU
	return diff

func _fire():
	print("BANG! Firing at ", current_target.name)

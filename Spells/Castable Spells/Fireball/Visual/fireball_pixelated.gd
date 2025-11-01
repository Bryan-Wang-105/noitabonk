# Fireball.gd
extends CharacterBody3D

var world

@export var lifetime: float = 5.0  # How long before auto-destroying
@export var damage: float = 100.0
@export var hit_effect_scene: PackedScene  # Optional particle effect for impact
@export var initial_speed: float = 10.0
@export var max_speed: float = 130.0
@export var acceleration: float = 35.0

# Physics properties
@export var mass: float = 50.0
@export var drag: float = 0.05  # Air resistance
@export var gravity_scale: float = 0.0  # Set to 0 for no gravity, 1.0 for normal gravity

var time_alive: float = 0.0
var direction: Vector3 = Vector3.FORWARD
var accumulated_forces: Vector3 = Vector3.ZERO

@onready var flame_trail: GPUParticles3D = $GPUParticles3D
var trail_process_material: ParticleProcessMaterial

func _ready():
	# Initialize velocity with initial speed in the direction
	velocity = direction * initial_speed
	
	# Add a timer to destroy the fireball after lifetime
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)
	
	# Get the process material created by FlameTrail script
	if flame_trail:
		trail_process_material = flame_trail.process_material as ParticleProcessMaterial
	

func apply_central_force(force: Vector3) -> void:
	"""
	Apply a force to the fireball (like wind, explosions, etc.)
	"""
	accumulated_forces += force

func apply_impulse(impulse: Vector3) -> void:
	"""
	Instantly change velocity (useful for deflection, bouncing, etc.)
	"""
	velocity += impulse / mass

func _physics_process(delta):
	time_alive += delta
	
	# Apply accumulated forces using F = ma
	var force_acceleration = accumulated_forces / mass
	velocity += force_acceleration * delta
	
	# Apply drag (air resistance)
	var speed = velocity.length()
	if speed > 0:
		var drag_force = velocity.normalized() * drag * speed * speed
		velocity -= drag_force * delta
	
	# Apply gravity if enabled
	if gravity_scale > 0:
		velocity.y -= 9.8 * gravity_scale * delta
	
	# Accelerate the fireball in its travel direction over time
	var current_speed = velocity.length()
	
	if current_speed < max_speed and current_speed > 0:
		# Add acceleration force in the direction of travel
		var travel_direction = velocity.normalized()
		var acceleration_force = travel_direction * acceleration * mass
		velocity += (acceleration_force / mass) * delta
		
		# Clamp to max speed
		if velocity.length() > max_speed:
			velocity = velocity.normalized() * max_speed
	
	# Update trail based on velocity
	_update_trail(delta)
	
	# Clear accumulated forces (they only apply for one frame)
	accumulated_forces = Vector3.ZERO
	
	# Move and detect collisions
	move_and_slide()
	
	# Check for collisions
	if get_slide_collision_count() > 0:
		var collision_obj = get_slide_collision(0).get_collider()
		_handle_collision(collision_obj)

func _update_trail(delta):
	if not flame_trail or not trail_process_material:
		return
	
	var speed = velocity.length()
	var speed_ratio = speed / max_speed  # 0.0 to 1.0
	
	# Particles emit backwards relative to movement
	if speed > 0.1:
		var emit_direction = -velocity.normalized()
		trail_process_material.direction = emit_direction
		trail_process_material.initial_velocity_min = speed * 0.3
		trail_process_material.initial_velocity_max = speed * 0.5
		trail_process_material.spread = 15.0 + (speed_ratio * 30.0)  # More spread at high speed
		
		# Scale particle emission with speed
		flame_trail.amount_ratio = 0.3 + (speed_ratio * 0.7)  # 30% to 100% particles
		
		# Adjust particle lifetime based on speed (faster = longer trail)
		flame_trail.lifetime = 0.3 + (speed_ratio * 0.7)  # 0.3s to 1.0s
	else:
		# Minimal trail when slow/stopped
		flame_trail.amount_ratio = 0.1

func _handle_collision(body):
	print("Fireball hit body: ", body)
	
	# Apply knockback force if the body supports it
	if body.has_method("apply_central_force") or body.has_method("apply_impulse"):
		var knockback_direction = velocity.normalized()
		var knockback_strength = velocity.length() * mass * 2.0  # Knockback based on momentum
		
		if body.has_method("apply_impulse"):
			body.apply_impulse(knockback_direction * knockback_strength)
		elif body.has_method("apply_central_impulse"):
			body.apply_central_impulse(knockback_direction * knockback_strength)
	
	# Check if the body can take damage
	if body.has_method("take_damage"):
		body.take_damage(damage)
	
	# Spawn hit effect if available
	if hit_effect_scene:
		var hit_effect = hit_effect_scene.instantiate()
		
		Global.world.add_child(hit_effect)
		hit_effect.global_position = global_position
		hit_effect.damage = damage
	
	# Destroy the fireball on impact
	queue_free()

func _on_lifetime_expired():
	queue_free()

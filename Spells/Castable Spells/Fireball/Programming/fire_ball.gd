# Fireball.gd
extends CharacterBody3D
class_name Fireball

var world

@export var lifetime: float = 5.0  # How long before auto-destroying
@export var damage: float = 100.0
@export var hit_effect_scene: PackedScene  # Optional particle effect for impact
@export var initial_speed: float = 10.0
@export var max_speed: float = 130.0
@export var acceleration: float = 35.0

# Physics properties
@export var mass: float = 75.0
@export var drag: float = 0.05  # Air resistance
@export var gravity_scale: float = 0.0  # Set to 0 for no gravity, 1.0 for normal gravity

var time_alive: float = 0.0
var direction: Vector3 = Vector3.FORWARD
var accumulated_forces: Vector3 = Vector3.ZERO

func _ready():
	# Initialize velocity with initial speed in the direction
	velocity = direction * initial_speed
	
	# Add a timer to destroy the fireball after lifetime
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)
	

func apply_central_force(force: Vector3) -> void:
	accumulated_forces += force

func apply_impulse(impulse: Vector3) -> void:
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
	
	# Clear accumulated forces (they only apply for one frame)
	accumulated_forces = Vector3.ZERO
	
	# Move and detect collisions
	move_and_slide()
	
	# Check for collisions
	if get_slide_collision_count() > 0:
		var collision_obj = get_slide_collision(0).get_collider()
		_handle_collision(collision_obj)


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

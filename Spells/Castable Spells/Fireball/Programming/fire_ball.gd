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

var time_alive: float = 0.0
var direction: Vector3 = Vector3.FORWARD

func _ready():
	# Initialize velocity with initial speed in the direction
	velocity = direction * initial_speed
	
	# Add a timer to destroy the fireball after lifetime
	var timer = get_tree().create_timer(lifetime)
	timer.timeout.connect(_on_lifetime_expired)

func _physics_process(delta):
	time_alive += delta
	
	# Accelerate the fireball over time
	var current_speed = velocity.length()
	#print(current_speed)
	if current_speed < max_speed:
		# Calculate new speed with acceleration
		var new_speed = min(current_speed + acceleration * delta, max_speed)
		
		# Maintain direction but increase speed
		velocity = velocity.normalized() * new_speed
	
	# Add some subtle vertical drop over time for more realistic trajectory
	velocity.y -= 0.5 * delta
	
	# Track previous position for trail effect (optional)
	var prev_pos = global_position
	
	# CharacterBody3D has a built-in velocity property
	# move_and_slide() will handle movement and detect collisions
	var collision = move_and_slide()
	
	# Check for collisions
	if get_slide_collision_count() > 0:
		var collision_obj = get_slide_collision(0).get_collider()
		_handle_collision(collision_obj)
	
	# Optional: Add visual effects based on speed
	if has_node("GPUParticles3D"):
		var particles = $Fireball/Sparks

		# Scale particle emission based on speed
		particles.amount_scale = current_speed / initial_speed

func _handle_collision(body):
	print("Fireball hit body: ", body)
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

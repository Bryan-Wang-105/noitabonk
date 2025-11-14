extends RigidBody3D

@export var pull_force: float = 50000.0

@onready var area: Area3D = $Area3D
@onready var particles1: GPUParticles3D = $GPUParticles3D
@onready var particles2: GPUParticles3D = $GPUParticles3D2
@onready var collision_area: CollisionShape3D = $Area3D/CollisionShape3D

var is_pulling: bool = false
var objects_in_range = []
var time_to_live = 8.0
var damage

func _ready() -> void:
	# Start timer for gravity pull
	await get_tree().create_timer(3.0).timeout
	_activate_gravity_pull()

func _activate_gravity_pull() -> void:
	particles1.emitting = true
	particles2.emitting = true
	
	# Stop the ball's movement
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true  # Make it stationary
	
	is_pulling = true
	
	await get_tree().create_timer(time_to_live).timeout
	_deactivate_pull()
	
func _deactivate_pull() -> void:
	is_pulling = false
	
	for body in objects_in_range:
		if has_method("stop_pull"):
			body.stop_pull()
	
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and body.is_in_group("physics") and body != self:
		objects_in_range.append(body)
	
	elif body is CharacterBody3D and body.is_in_group("physics") and body != self:
		#print(body)
		objects_in_range.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body in objects_in_range:
		if body.has_method("stop_pull"):
			body.stop_pull()
	
		objects_in_range.erase(body)

var damage_timer: float = 0.0
const DAMAGE_INTERVAL: float = 0.5

func _deal_damage_to_enemies() -> void:
	for body in objects_in_range:
		if body.is_in_group("enemy"):
			if body.has_method("take_dmg"):
				# Calculate distance from center
				var distance = global_position.distance_to(body.global_position)
				
				# Calculate damage falloff (1.0 at center, 0.5 at max range)
				# Normalize distance: 0 at center, 1 at edge
				var normalized_distance = distance / collision_area.shape.radius
				
				# Interpolate damage: full damage at center, half damage at edge
				var damage_multiplier = lerp(1.0, 0.5, normalized_distance)
				
				var final_damage = damage * damage_multiplier
				
				body.take_dmg(final_damage)

func _physics_process(delta: float) -> void:
	if not is_pulling:
		return
	
	# Increment damage timer
	damage_timer += delta
	
	# Deal damage every 0.5 seconds
	if damage_timer >= DAMAGE_INTERVAL:
		damage_timer = 0.0  # Reset timer
		_deal_damage_to_enemies()
	
	# Apply pull force to all objects in range
	for body in objects_in_range:
		if is_instance_valid(body):
			#print("Pulling ", body)
			var direction = (global_position - body.global_position).normalized()
			var distance = global_position.distance_to(body.global_position)
			
			# Stronger pull when closer (inverse square law optional)
			var force_strength = pull_force / max(distance, 1.0)
			
			body.apply_central_force(direction * force_strength)

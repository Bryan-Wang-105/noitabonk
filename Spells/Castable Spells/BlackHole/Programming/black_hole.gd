extends RigidBody3D

@export var pull_force: float = 500000.0

@onready var area: Area3D = $Area3D

var is_pulling: bool = false
var objects_in_range: Array[RigidBody3D] = []

func _ready() -> void:
	# Start timer for gravity pull
	await get_tree().create_timer(3.0).timeout
	_activate_gravity_pull()

func _activate_gravity_pull() -> void:
	# Stop the ball's movement
	linear_velocity = Vector3.ZERO
	angular_velocity = Vector3.ZERO
	freeze = true  # Make it stationary
	
	is_pulling = true
	
	await get_tree().create_timer(8.0).timeout
	_deactivate_pull()
	
func _deactivate_pull() -> void:
	is_pulling = false
	queue_free()

func _on_body_entered(body: Node3D) -> void:
	if body is RigidBody3D and body.is_in_group("physics") and body != self:
		objects_in_range.append(body)

func _on_body_exited(body: Node3D) -> void:
	if body in objects_in_range:
		objects_in_range.erase(body)

func _physics_process(delta: float) -> void:
	if not is_pulling:
		return
	
	# Apply pull force to all objects in range
	for body in objects_in_range:
		if is_instance_valid(body):
			var direction = (global_position - body.global_position).normalized()
			var distance = global_position.distance_to(body.global_position)
			
			# Stronger pull when closer (inverse square law optional)
			var force_strength = pull_force / max(distance, 1.0)
			
			body.apply_central_force(direction * force_strength)

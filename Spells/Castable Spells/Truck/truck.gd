extends RigidBody3D

@export var drive_force: float = 50.0

func _ready() -> void:
	activate_timer()
	pass

func activate_timer() -> void:
	await get_tree().create_timer(10.0).timeout

	queue_free()

func _physics_process(delta: float) -> void:
	# Apply force in the direction the truck is facing
	var forward_direction = -global_transform.basis.z
	
	#if is_on_floor():
	#add_constant_central_force(forward_direction * drive_force)

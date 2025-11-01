extends RigidBody3D

@export var drive_force: float = 50.0

@export var max_damage_speed: float = 60.0
@export var damage_multiplier: float = 1.0

@onready var area: Area3D = $Area3D

var dmg
var bodies_in_area: Array = []

func _ready() -> void:
	# Connect Area3D signals
	area.body_entered.connect(_on_area_body_entered)
	area.body_exited.connect(_on_area_body_exited)
	
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

func _on_area_body_entered(body: Node3D) -> void:
	print("TRUCK HIT BODY")
	# Add to our tracking array
	if body not in bodies_in_area:
		bodies_in_area.append(body)
	
	# Calculate damage based on speed
	var current_speed = linear_velocity.length()
	var ang_speed = angular_velocity.length()
	
	
	print("SPEEDS")
	print(current_speed)
	print(ang_speed)
	
	if current_speed + ang_speed < 5:
		return
	else:
		var speed_ratio = clamp((current_speed+ang_speed) / max_damage_speed, 0.0, 1.0)
		var damage = speed_ratio * damage_multiplier * max_damage_speed
		
		# Apply damage if the body has a take_dmg method
		if body.has_method("take_dmg") and damage > 0:
			body.take_dmg(damage)

func _on_area_body_exited(body: Node3D) -> void:
	# Remove from tracking array
	if body in bodies_in_area:
		bodies_in_area.erase(body)

extends RigidBody3D


@export var lifetime: float = 5.0  # How long before auto-destroying
@export var damage: float = 10.0
@export var hit_effect_scene: PackedScene  # Optional particle effect for impact
@export var initial_speed: float = 60.0
@export var max_speed: float = 130.0
@export var acceleration: float = 35.0

@export var max_damage_speed: float = 15.0
@export var damage_multiplier: float = 1.0

@onready var trail_particles: GPUParticles3D = $trailMesh

# Physics properties
@export var drag: float = 0.05  # Air resistance\

var time_alive: float = 0.0
var direction: Vector3 = Vector3.FORWARD
var accumulated_forces: Vector3 = Vector3.ZERO

func _ready():
	body_entered.connect(_on_body_entered)
	# Initialize velocity with initial speed in the direction
	linear_velocity = direction * initial_speed
	
	activate_timer()

func activate_timer() -> void:
	await get_tree().create_timer(4.0).timeout

	queue_free()

func _physics_process(delta):
	pass

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("enemy"):
		
		# Calculate damage based on speed
		var current_speed = linear_velocity.length()
		
		if current_speed < 5:
			return
		else:
			var speed_ratio = clamp((current_speed) / max_damage_speed, 0.0, 1.0)
			var damage = round(speed_ratio * damage_multiplier * max_damage_speed)
			print(damage)
			
			# Apply damage if the body has a take_dmg method
			if body.has_method("take_dmg") and damage > 0:
				body.take_dmg(damage)

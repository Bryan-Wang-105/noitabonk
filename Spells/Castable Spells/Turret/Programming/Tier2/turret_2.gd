extends RigidBody3D

# Need to get line of sight to enemies not going through walls

@onready var top_half: Node3D = $topTurretMesh
@onready var area: Area3D = $Area3D
@onready var anim_player: AnimationPlayer = $AnimationPlayer

@onready var gpu1: GPUParticles3D = $topTurretMesh/GPUParticles3D
@onready var gpu2: GPUParticles3D = $topTurretMesh/GPUParticles3D2
@onready var gpu3: GPUParticles3D = $topTurretMesh/GPUParticles3D3

var dmg
var enemies_in_range: Array = []
var current_target: Node3D = null
var rotation_speed: float = 30.0  # Radians per second
var fire_rate: float = 0.5  # Seconds between shots
var time_since_last_shot: float = 0.0

func _ready():
	# Connect area signals
	area.body_entered.connect(_on_body_entered)
	area.body_exited.connect(_on_body_exited)

	activate_timer()

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
		anim_player.pause()
		gpu1.emitting = true
		gpu2.emitting = true
		gpu3.emitting = true
		#_rotate_towards_target(delta)
		top_half.look_at(current_target.to_aim.global_position)
		
		# Fire at target if enough time has passed
		if time_since_last_shot >= fire_rate:
			_fire()
			time_since_last_shot = 0.0
	else:
		if !anim_player.is_playing():
			anim_player.play("idle")
			
			gpu1.emitting = false
			gpu2.emitting = false
			gpu3.emitting = false

func _on_body_entered(body):
	# Check if the body is an enemy (adjust this condition based on your game)
	if body.is_in_group("enemy"):
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

func _fire():
	print("BANG! Firing")
	if current_target.has_method("take_dmg"):
		current_target.take_dmg(dmg)

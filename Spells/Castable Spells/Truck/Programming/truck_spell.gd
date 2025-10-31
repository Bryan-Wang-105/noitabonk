# truck_Spell.gd - summons a blackhole
extends Spell


@export var launch_speed: float = 20.0
@export var spawn_distance: float = 3.5 # Distance from player to spawn the fireball

func _init():
	name = "Pickup Truck"
	rarity = "Uncommon"
	projectile_scene = preload("uid://dng6nvqqy7qvd")
	projectile_sound = null#load("uid://kqqsvhd1vj0a")
	icon_path = "uid://dv2n8cm2gks55"
	cast_delay = 1.0
	damage = 100
	modifier = false
	description = "This baby can haul all the groceries you can buy"

func activate(sprd = 0):
	spawn_truck(sprd)

func spawn_truck(sprd = 0):
	# Instantiate the fireball
	var truck_instance = projectile_scene.instantiate()
	
	# Get the forward direction from the camera (facing direction)
	var forward_direction = -Global.player.camera.global_transform.basis.z.normalized()
	
	if sprd != 0:
		forward_direction = apply_spread(sprd * 100, forward_direction)
	
	# Calculate the spawn position relative to the player
	var spawn_position = Global.player.camera.global_position + (forward_direction * spawn_distance)
	spawn_position.y -= 1 
	
	# Set up transforms before adding to scene tree
	truck_instance.transform.origin = spawn_position
	
	# Set up orientation using basis directly
	var look_target = Global.player.camera.global_position + forward_direction * 10.0
	var z_axis = (spawn_position - look_target).normalized()
	var x_axis = Vector3.UP.cross(z_axis).normalized()
	var y_axis = z_axis.cross(x_axis).normalized()
	truck_instance.transform.basis = Basis(x_axis, y_axis, z_axis)
	
	# Set the velocity data
	#truck_instance.direction = forward_direction
	truck_instance.linear_velocity = forward_direction * launch_speed
	
	
	# Now add the fully configured fireball to the scene
	Global.world.add_child(truck_instance)

	# Add sound effect for the fireball launch
	if projectile_sound:
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = projectile_sound
		audio_player.autoplay = true
		audio_player.max_distance = 30 # Adjust based on your game scale
		audio_player.unit_size = 10.0 # Adjust based on your game scale
		truck_instance.add_child(audio_player)

func apply_spread(sprd, forward_direction):
	# Convert spread from degrees to radians
	var spread_radians = deg_to_rad(sprd)
	
	# Random angles within the spread cone
	var random_yaw = randf_range(-spread_radians, spread_radians)
	var random_pitch = randf_range(-spread_radians, spread_radians)
	
	# Create rotation basis for the spread
	var spread_basis = Basis()
	spread_basis = spread_basis.rotated(Vector3.UP, random_yaw)
	spread_basis = spread_basis.rotated(Vector3.RIGHT, random_pitch)
	
	# Apply spread to forward direction
	forward_direction = spread_basis * forward_direction
	forward_direction = forward_direction.normalized()
	
	return forward_direction

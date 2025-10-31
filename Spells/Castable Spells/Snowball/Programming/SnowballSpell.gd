# Snowball_Spell.gd - Shoots a snowball in the direction the player is facing
#class_name Snowball_Spell
extends Spell

@export var launch_speed: float = 20.0
@export var spawn_distance: float = .5 

func _init():
	name = "Snowball"
	rarity = "Uncommon"
	projectile_scene = preload("uid://bmxm7ahckgd3g")
	icon_path = "uid://b78qudd2h5dy0"
	projectile_sound = load("uid://c323v5kn0omhc")
	cast_delay = 0.15
	damage = 80
	modifier = false
	description = "A freezing ball of ice"
	
func activate(sprd = 0):
	spawn_snowball(sprd)

func spawn_snowball(sprd = 0):
	# Instantiate the snowball
	var snowball_instance = projectile_scene.instantiate()
	
	# Get the forward direction from the camera (facing direction)
	var forward_direction = -Global.player.camera.global_transform.basis.z.normalized()
	
	if sprd != 0:
		forward_direction = apply_spread(sprd * 100, forward_direction)
	
	# Calculate the spawn position relative to the player
	var spawn_position = Global.player.camera.global_position + (forward_direction * spawn_distance)
	
	# Set up transforms before adding to scene tree
	snowball_instance.transform.origin = spawn_position
	
	# Set up orientation using basis directly
	var look_target = Global.player.camera.global_position + forward_direction * 10.0
	var z_axis = (spawn_position - look_target).normalized()
	var x_axis = Vector3.UP.cross(z_axis).normalized()
	var y_axis = z_axis.cross(x_axis).normalized()
	snowball_instance.transform.basis = Basis(x_axis, y_axis, z_axis)
	
	# Set the velocity data
	snowball_instance.direction = forward_direction
	snowball_instance.velocity = forward_direction * launch_speed
	
	# Now add the fully configured fireball to the scene
	Global.world.add_child(snowball_instance)

	# Add sound effect for the snowball launch
	if projectile_sound:
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = projectile_sound
		audio_player.autoplay = true
		audio_player.max_distance = 30 # Adjust based on your game scale
		audio_player.unit_size = 10.0 # Adjust based on your game scale
		snowball_instance.add_child(audio_player)

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

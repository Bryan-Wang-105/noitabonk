# Bouncing_ball_spell.gd - Shoots a bouncing_ball in the direction the player is facing
extends Spell


@export var launch_speed: float = 40.0
@export var spawn_distance: float = .5 # Distance from player to spawn the fireball

func _init():
	name = "Bouncing Ball"
	rarity = "Common"
	projectile_scene = preload("uid://ilq773iptj75")
	projectile_sound = null
	icon_path = "uid://cclpsgje314oj"
	cast_delay = -.02
	damage = 5
	modifier = false
	description = "A bouncing ball of goo"

func activate(sprd = 0):
	spawn_bounce_ball(sprd)

func spawn_bounce_ball(sprd = 0):
	# Instantiate the fireball
	var bounce_projectile = projectile_scene.instantiate()
	
	# Get the forward direction from the camera (facing direction)
	var forward_direction = -Global.player.camera.global_transform.basis.z.normalized()
	#var forward_direction = -Global.player.global_transform.basis.z.normalized()
	
	if sprd != 0:
		forward_direction = apply_spread(sprd * 100, forward_direction)
	
	# Calculate the spawn position relative to the player
	var spawn_position = Global.player.camera.global_position + (forward_direction * spawn_distance)
	
	# Set up transforms before adding to scene tree
	bounce_projectile.transform.origin = spawn_position
	
	# Set up orientation using basis directly
	var look_target = Global.player.camera.global_position + forward_direction * 10.0
	var z_axis = (spawn_position - look_target).normalized()
	var x_axis = Vector3.UP.cross(z_axis).normalized()
	var y_axis = z_axis.cross(x_axis).normalized()
	bounce_projectile.transform.basis = Basis(x_axis, y_axis, z_axis)
	
	# Set the velocity data
	bounce_projectile.direction = forward_direction
	bounce_projectile.linear_velocity = forward_direction * launch_speed
	
	# Now add the fully configured fireball to the scene
	Global.world.add_child(bounce_projectile)

	# Add sound effect for the fireball launch
	if projectile_sound:
		var audio_player = AudioStreamPlayer3D.new()
		audio_player.stream = projectile_sound
		audio_player.autoplay = true
		audio_player.max_distance = 30 # Adjust based on your game scale
		audio_player.unit_size = 10.0 # Adjust based on your game scale
		bounce_projectile.add_child(audio_player)

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

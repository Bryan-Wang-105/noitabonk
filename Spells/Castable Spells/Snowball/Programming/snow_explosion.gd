extends Node3D

@onready var animation_node: AnimationPlayer = $VFX_Explosion/AnimationPlayer
@onready var explosion_area: Area3D = $ExplosionArea
@onready var explosion_collider: CollisionShape3D = $ExplosionArea/ExplosionCollider

var player_name
var player_id

var damage
var type = "ice"
var force_amt = 300
var slow_amt = .6
var slow_time = 1.5
var source_group: String = "" # The group of the entity that created this explosion

func _ready():
	# Connect to the appropriate signal based on animation node type
	if animation_node is AnimationPlayer:
		animation_node.animation_finished.connect(_on_animation_finished)

	print("Ice Explosion Spawned")
	await get_tree().process_frame
	await get_tree().physics_frame # even safer
	var bodies = explosion_area.get_overlapping_bodies()
	explode(bodies)

func _on_animation_finished(anim_name = ""):
	# If animation_name is specified, only delete when that specific animation finishes
	if anim_name == "Boom":
		queue_free()

# Helper function to check if a ray hits a target
func _check_ray_hit(target: Node3D) -> bool:
	# Check multiple rays from explosion to different parts of the target
	var target_points = [
		target.global_transform.origin,
		target.global_transform.origin + Vector3(0, 0.1, 0),
		target.global_transform.origin + Vector3(0, -.1, 0),
		target.global_transform.origin + Vector3(0, 0, .1),
		target.global_transform.origin + Vector3(0, 0, -.1),
		target.global_transform.origin + Vector3(.1, 0, 0),
		target.global_transform.origin + Vector3(-.1, 0, 0)
	]
	for point in target_points:
		var ray_origin = global_transform.origin
		var rayParams = PhysicsRayQueryParameters3D.create(ray_origin, point)
		rayParams.exclude = [self]
		var result = get_world_3d().direct_space_state.intersect_ray(rayParams)

		# If the ray hits the target or nothing, count it as a hit
		if len(result) == 0 or (result.collider == target):
			return true

	return false

# Helper function to handle damage application
func _apply_damage(target: Node3D) -> void:
	if target.has_method("take_dmg") and target.is_in_group("enemy"):
		target.take_dmg(damage)
		if target.has_method("apply_slow"):
			print("EXPLOSION APPLYING SLOW")
			target.apply_slow(slow_amt, slow_time)
	else:
		print("\nENEMY Hit with damage: ", damage)
		target.get_node("Damageable").take_damage(damage, type, false)

# Helper function to handle physics force
func _apply_physics_force(target: Node3D) -> void:
	if target.has_method("apply_force_from"):
		var source = self.global_transform.origin
		target.apply_force_from(source, force_amt)

func explode(bodies) -> void:
	print("\nEXPLODING!")
	print("Collided with these bodies", bodies)

	for obj in bodies:
		# Skip if the object is in the same group as the source (friendly fire prevention)
		if source_group != "" and obj.is_in_group(source_group):
			continue

		# Handle damageable targets (enemies or player)
		if obj.is_in_group("enemy") or obj.is_in_group("players"):
			if _check_ray_hit(obj):
				_apply_damage(obj)

		# Handle physics objects
		if obj.is_in_group("physics"):
			_apply_physics_force(obj)

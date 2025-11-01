extends CharacterBody3D

@export var loot: PackedScene

@onready var ray: RayCast3D = $RayCast3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var sunglass_mesh: CSGBox3D = $CSGBox3D
@onready var to_aim: Node3D = $toAim

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed = 3.0
var health = 300
var locked = false
var force = 50
var alive = true
var level = 0

func take_dmg(amount):
	print("ENEMY TOOK DAMAGE")
	flash_white()
	health -= amount
	
	if health <= 0:
		print("ENEMY IS DEAD")
		alive = false
		die()

func flash_white() -> void:
	# Set white material as override (only affects THIS enemy)
	mesh.set_surface_override_material(0, load("uid://dwt5nwlmv0bwq"))
	sunglass_mesh.material_override = load("uid://6w0io6vltb80")
	
	# Wait 0.15 seconds
	await get_tree().create_timer(0.15).timeout
	
	# Restore original material
	mesh.set_surface_override_material(0, load("uid://da05kka4mhv1w"))
	sunglass_mesh.material_override = load("uid://cpm6h6ptlfmpn")


func die():
	# Chance to drop loot (20%)
	if randi_range(1,10) < 2:
		# Chance to drop upgraded loot to Uncommon (4%)
		if randi_range(1,10) < 2:
			level = 1
			print("Spawning loot at level 1")
		
		var spawn_loot = loot.instantiate()
		spawn_loot.generate_random_wand(level)
		
		Global.world.add_child(spawn_loot)
		spawn_loot.global_position = global_position
		spawn_loot.global_position.y += .25
		
	queue_free()

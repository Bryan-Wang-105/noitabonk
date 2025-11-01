extends CharacterBody3D

@export var loot: PackedScene

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed = 3.0
var health = 10
var locked = false
var force = 50
var alive = true
var level = 0

func take_dmg(amount):
	print("ENEMY TOOK DAMAGE")
	health -= amount
	
	if health <= 0:
		print("ENEMY IS DEAD")
		alive = false
		die()


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

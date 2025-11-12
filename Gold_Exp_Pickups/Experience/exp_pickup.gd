extends RigidBody3D

var amount
var pick_up_type = "xp"

func _ready():
	if amount == null:
		set_amount()

func set_amount(enemy_level = 0):
	# Is 0 by default
	if enemy_level == 0:
		amount = randi_range(20, 80) * Global.enemy_manager.difficulty
	elif enemy_level == 1:
		amount = randi_range(8, 18) * Global.enemy_manager.difficulty
	elif enemy_level == 2:
		amount = randi_range(18, 48) * Global.enemy_manager.difficulty

func delete():
	# Delete current reference
	# Hide immediately but delete next frame
	visible = false
	collision_layer = 0
	call_deferred("queue_free")
	queue_free()

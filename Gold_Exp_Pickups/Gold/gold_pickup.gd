extends RigidBody3D


var amount

func _ready():
	if amount == null:
		set_amount()

func set_amount(enemy_level = 0):
	# Is 0 by default
	if enemy_level == 0:
		amount = randi_range(1, 4)
	elif enemy_level == 1:
		amount = randi_range(4, 9)
	elif enemy_level == 2:
		amount = randi_range(9, 24)

func _on_body_entered(body) -> void:
	# Send audio cmd
	Global.audio_node.play_gold_pickup_fx()
	
	# Update player gold count
	Global.playerManager.add_gold(amount)
	
	# Delete current reference
	# Hide immediately but delete next frame
	visible = false
	collision_layer = 0
	call_deferred("queue_free")
	queue_free()

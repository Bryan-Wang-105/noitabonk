extends RigidBody3D

signal gold_collected

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

func _on_body_entered(body: Node3D) -> void:
	# Send audio cmd
	Global.audio_node.play_gold_pickup_fx()
	
	# Update player gold count
	Global.playerManager.add_gold(amount)
	
	# Delete current reference
	queue_free()

func _on_body_exited(body: Node3D) -> void:
	print("Player Exited!")

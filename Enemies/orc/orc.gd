extends CharacterBody3D

@export var loot: PackedScene
@onready var ray: RayCast3D = $RayCast3D
@onready var to_aim: Node3D = $toAim

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var collider: CollisionShape3D = $CollisionShape3D
@onready var anim: AnimationPlayer = $AnimationPlayer

var base_speed = 4.0
var speed = 4.0
var health = 30

var accumulated_forces: Vector3 = Vector3.ZERO
var level = 0
var alive = true

var being_pulled = false
var mass = 100

var attack_timer: Timer
var is_attacking
@onready var attack_radius = collider.shape.radius + Global.player.collider.shape.radius + 5
var can_attack = true
var attack_dmg = 5
const ATTACK_INTERVAL: float = 5.0  # Time between attacks in seconds

func _ready():
	# Create and setup the timer
	attack_timer = Timer.new()
	attack_timer.wait_time = ATTACK_INTERVAL
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

func apply_slow(slow_amt, time):
	print("APPLYING SLOW")
	# Set to new value
	speed = base_speed * slow_amt

	# Wait 4 seconds
	await get_tree().create_timer(time).timeout

	# Restore original value
	speed = base_speed

func take_dmg(amount):
	print("ENEMY TOOK DAMAGE")
	
	# Calculate crit opportunity
	var crit = randi_range(1, 100)
	var critted = false
	
	if crit <= Global.playerManager.critical_strike_chance * 100:
		critted = true
		amount *= ((100 +  Global.playerManager.critical_strike_dmg)/100)
		
	# Show damage number
	Global.dmg_num_pool.show_damage(amount, global_position, critted)
	
	# Apply lifesteal if exists
	if Global.playerManager.life_steal > 0:
		var heal_amt = amount * (Global.playerManager.life_steal)
		Global.playerManager.add_health(heal_amt)
		
		# Show damage number
		Global.dmg_num_pool.show_heal(heal_amt, Global.player.heal_num.global_position)
	
	
	# Subtract health
	health -= amount
	
	if health <= 0:
		print("ENEMY IS DEAD 1")
		alive = false
		#die()

func die():
	# 30% to drop gold and xp
	if randi_range(0, 100) + Global.playerManager.luck > 10:
		var gold_drop = load("uid://c7fyfw2mhsj5g") 
		gold_drop = gold_drop.instantiate()
		gold_drop.set_amount(level)
		Global.world.add_child(gold_drop)
		gold_drop.global_position = global_position
		gold_drop.global_position.y += .25
		gold_drop.global_position.x += randf_range(-.25, .25)
		gold_drop.global_position.z += randf_range(-.25, .25)
		
	# 30% to drop gold and xp
	if randi_range(0, 100) + Global.playerManager.luck > 10:
		# Always drop xp
		var xp_drop = load("uid://dpi1yh7clswrh") 
		
		xp_drop = xp_drop.instantiate()
		xp_drop.set_amount(level)
		
		Global.world.add_child(xp_drop)
		xp_drop.global_position = global_position
		xp_drop.global_position.y += .25
		xp_drop.global_position.x += randf_range(-.25, .25)
		xp_drop.global_position.z += randf_range(-.25, .25)
	
	# Chance to drop special loot (10%)
	if randi_range(0,100) + Global.playerManager.luck > 80:
		# Chance to drop upgraded loot to Uncommon (2%)
		if randi_range(0,100) + Global.playerManager.luck > 80:
			level = 1
			print("Spawning loot at level 1")
		
		var spawn_loot = loot.instantiate()
		spawn_loot.generate_random_wand(level)
		
		Global.world.add_child(spawn_loot)
		spawn_loot.global_position = global_position
		spawn_loot.global_position.y += .25
		
	queue_free()


func apply_central_force(force: Vector3) -> void:
	being_pulled = true
	accumulated_forces += force

func apply_impulse(impulse: Vector3) -> void:
	pass
	#velocity += impulse / mass

func stop_pull():
	being_pulled = false

func attack_player():
	if can_attack:
		# Stop walk animation and play attack animation
		anim.stop()
		anim.play("jump attack", 0.0, 2.0)
		
		speed = 12
		is_attacking = true
		
		# Apply jump force
		velocity.y = 8.0  # Adjust this value for jump height
		
		Global.playerManager.take_damage(attack_dmg)
	
		# Start cooldown AFTER animation finishes
		can_attack = false

func _on_attack_timer_timeout():
	can_attack = true
	
func _physics_process(delta):
	# Check if jump attack animation just finished
	if is_attacking and not anim.is_playing():
		is_attacking = false
		speed = base_speed
		anim.play("walk")
		attack_timer.start()  # Start cooldown timer here
	
	# ----- TRANSITION TO RUN LOOP -----
	# Only resume walk if not attacking
	elif not anim.is_playing() and not is_attacking:
		anim.play("walk")

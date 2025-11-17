extends CharacterBody3D

@export var loot: PackedScene
@onready var ray: RayCast3D = $RayCast3D
@onready var mesh: MeshInstance3D = $MeshInstance3D
@onready var sunglass_mesh: CSGBox3D = $CSGBox3D
@onready var to_aim: Node3D = $toAim
@onready var body: MeshInstance3D = $MeshInstance3D

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var speed = 3.0
var health = 600

var accumulated_forces: Vector3 = Vector3.ZERO
var level = 2
var alive = true

var being_pulled = false
var mass = 300

var attack_timer: Timer
var attack_radius = 1.25
var can_attack = true
var attack_dmg = 50
var attack_cooldown: float = 2.0
const ATTACK_INTERVAL: float = 2.0  # Time between attacks in seconds

func _ready():
	# Create and setup the timer
	attack_timer = Timer.new()
	attack_timer.wait_time = ATTACK_INTERVAL
	attack_timer.one_shot = true
	attack_timer.timeout.connect(_on_attack_timer_timeout)
	add_child(attack_timer)

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
		print("ENEMY IS DEAD")
		alive = false
		#die()
		
	Global.dmg_display.flash_dmg(body, critted)

func flash_white() -> void:
	# Set white material as override (only affects THIS enemy)
	mesh.set_surface_override_material(0, load("uid://dwt5nwlmv0bwq"))
	sunglass_mesh.material_override = load("uid://6w0io6vltb80")
	
	# Wait 0.15 seconds
	await get_tree().create_timer(0.15).timeout
	
	# Restore original material
	mesh.set_surface_override_material(0, load("uid://bwgqwkd3ha23s"))
	sunglass_mesh.material_override = load("uid://cpm6h6ptlfmpn")


func die():
	# 100% to drop gold and xp
	if randi_range(71, 100) + Global.playerManager.luck > 70:
		var gold_drop = load("uid://c7fyfw2mhsj5g") 
		gold_drop = gold_drop.instantiate()
		gold_drop.set_amount(level)
		Global.world.add_child(gold_drop)
		gold_drop.global_position = global_position
		gold_drop.global_position.y += .25
		gold_drop.global_position.x += randf_range(-.25, .25)
		gold_drop.global_position.z += randf_range(-.25, .25)
		
	# 100% to drop gold and xp
	if randi_range(71, 100) + Global.playerManager.luck > 70:
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
	if randi_range(0,100) + Global.playerManager.luck > 50:
		# Chance to drop upgraded loot to Uncommon (2%)
		if randi_range(0,100) + Global.playerManager.luck > 50:
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
	velocity += impulse / mass

func stop_pull():
	being_pulled = false

func attack_player():
	if can_attack:
		Global.playerManager.take_damage(attack_dmg)
	
		# Start cooldown
		can_attack = false
		attack_timer.start()

func _on_attack_timer_timeout():
	can_attack = true
	
func _physics_process(delta):
	if being_pulled:
		# Apply accumulated forces using F = ma
		var force_acceleration = accumulated_forces / mass
		velocity += force_acceleration * delta
		
		# Accelerate the fireball in its travel direction over time
		var current_speed = velocity.length()
		
		# Clear accumulated forces (they only apply for one frame)
		accumulated_forces = Vector3.ZERO
	

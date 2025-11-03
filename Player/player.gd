extends CharacterBody3D

# Movement variables
@export var sensitivity := 0.003

# Get the gravity from the project settings
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

# References
@onready var head := $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var spawn_spell_pos: Node3D = $Head/spawnSpellPos

#@onready var wand_inventory: WandInventory = $WandInventory
#@onready var wand_controller: WandController = $WandController

var wand_inventory
var wand_controller

var player_locked = false

func _ready() -> void:
	Global.player = self
	wand_inventory = Global.wandInventory
	wand_controller = Global.wandController
	
	# Capture the mouse cursor
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	var starter_wand = WandData.new()
	
	wand_inventory.add_wand_auto(starter_wand)

func is_busy(status):
	player_locked = status


func _input(event: InputEvent) -> void:
	if player_locked:
		return
	
	# Handle mouse movement for camera rotation
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		# Rotate player body left/right
		rotate_y(-event.relative.x * sensitivity)
		# Rotate head up/down
		head.rotate_x(-event.relative.y * sensitivity)
		# Clamp vertical rotation to prevent over-rotation
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)

func _physics_process(delta: float) -> void:
	# Add gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor() and !player_locked:
		velocity.y = Global.playerManager.jump_height

	# Get input direction
	if !player_locked:
		var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
		
		# Calculate movement direction relative to where the player is looking
		var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		
		# Apply sprint
		var sprint = Global.playerManager.sprint_speed
		var walk = Global.playerManager.walk_speed
		
		var current_speed =  sprint if Input.is_action_pressed("ui_shift") else walk
		
		# Move the player
		if direction:
			velocity.x = direction.x * current_speed
			velocity.z = direction.z * current_speed
		else:
			velocity.x = move_toward(velocity.x, 0, current_speed)
			velocity.z = move_toward(velocity.z, 0, current_speed)
	else:
		if is_on_floor():
			velocity.x = 0
			velocity.z = 0
	
	move_and_slide()

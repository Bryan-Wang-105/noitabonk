# WandController.gd
extends Node
class_name WandController

# Reference to current wand data
var current_wand: WandData = null

# Shooting state
var shooting: bool = false
var is_locked: bool = false
var is_reloading: bool = false

# Timers
var cast_delay_timer: float = 0.0
var reload_timer: float = 0.0

# Current spell index
var curr_idx: int = 0

# Reference to where spells spawn (set this from player)
@export var spell_spawn_point: Node3D

signal spell_cast(spell: Resource)
signal reload_started()
signal reload_finished()

func _ready() -> void:
	Global.wandController = self
	# Connect to inventory if it exists
	var inventory = get_parent().get_node_or_null("WandInventory")
	if inventory:
		inventory.wand_equipped.connect(_on_wand_equipped)

func _input(event: InputEvent) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		if event.is_action_pressed("l_click"):
			shooting = true
		
		if event.is_action_released("l_click"):
			shooting = false

func _process(delta: float) -> void:
	# Handle cast delay cooldown
	if cast_delay_timer > 0:
		cast_delay_timer -= delta
		if cast_delay_timer <= 0:
			is_locked = false
	
	# Handle reload cooldown
	if is_reloading:
		reload_timer -= delta
		if reload_timer <= 0:
			finish_reload()
	
	# Shoot if button held
	if shooting:
		shoot()

func shoot() -> void:
	# Check if we have a wand equipped
	if current_wand == null:
		return
	
	# Check if wand is locked
	if is_locked or is_reloading:
		return
	
	# Check if we have spells to cast
	if not current_wand.has_spells() or curr_idx >= current_wand.spells.size():
		return
	
	# Get current spell
	var current_spell = current_wand.get_spell(curr_idx)
	
	# Skip null slots
	if current_spell == null:
		print("BLANK")
		increment()
		return
	
	# Cast the spell
	current_spell.activate(current_wand.spread)
	spell_cast.emit(current_spell)
	
	# Lock wand for cast delay
	is_locked = true
	cast_delay_timer = current_spell.cast_delay + current_wand.cast_delay

	# If this is the last valid spell, start reload *now* alongside cast delay
	if is_last_valid_spell():
		start_reload()
	
	print("CAST DELAY FROM SPELL: ", current_spell.cast_delay)
	print("CAST DELAY FROM WAND: ", current_wand.cast_delay)
	
	# Move to next spell
	increment()

func increment() -> void:
	curr_idx += 1
	
	# Check if we've cast all spells
	if curr_idx >= current_wand.capacity:
		start_reload()
		print("RELOAD TIME: ", current_wand.reload_speed)

func start_reload() -> void:
	if current_wand == null:
		return
	
	is_reloading = true
	# Don't override is_locked — it may already be true from cast delay
	reload_timer = current_wand.reload_speed
	reload_started.emit()

func finish_reload() -> void:
	is_reloading = false

	# Only unlock if cast delay is also done
	if cast_delay_timer <= 0:
		is_locked = false
	else:
		# If cast delay is still active, keep locked until it ends
		is_locked = true

	curr_idx = 0
	reload_finished.emit()


func can_shoot() -> bool:
	return current_wand != null and not is_locked and not is_reloading

# Called when inventory equips a new wand
func _on_wand_equipped(wand_data: WandData, slot: int) -> void:
	load_wand(wand_data)

# Load a wand's data into the controller
func load_wand(wand_data: WandData) -> void:
	current_wand = wand_data
	curr_idx = 0
	is_locked = false
	is_reloading = false
	cast_delay_timer = 0.0
	reload_timer = 0.0
	shooting = false

func is_last_valid_spell() -> bool:
	if current_wand == null:
		return false

	# If we are already on the final slot
	if curr_idx >= current_wand.capacity - 1:
		return true

	# Otherwise, check if all remaining slots are null
	for i in range(curr_idx + 1, current_wand.capacity):
		if current_wand.get_spell(i) != null:
			return false
	return true

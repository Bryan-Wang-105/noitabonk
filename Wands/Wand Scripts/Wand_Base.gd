# Basic wand prototype (will add spell modifiers etc later)
extends Node
class_name Wand

var capacity
var reload_speed
var cast_delay
var spread
var spells = [] #Sized capacity
var curr_idx = 0

# Lock variables
var shooting
var is_locked: bool = false
var cast_delay_timer: float = 0.0
var is_reloading: bool = false
var reload_timer: float = 0.0

func _input(event: InputEvent) -> void:
	# Handle mouse movement for camera rotation
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
			is_reloading = false
			curr_idx = 0  # Reset to first spell
			print("Reload complete!")
	
	if shooting:
		shoot()

func shoot():
	# Check if wand is locked
	if is_locked or is_reloading:
		print("Wand is locked!")
		return
	
	# Check if we have spells
	if spells.is_empty() or curr_idx >= spells.size():
		print("No spells to cast!")
		return
	
	# Cast the spell
	var current_spell = spells[curr_idx]
	current_spell.activate()
	
	# Lock wand for cast delay
	is_locked = true
	cast_delay_timer = current_spell.cast_delay + cast_delay
	
	# Move to next spell
	increment()

func increment():
	curr_idx += 1
	
	if curr_idx >= capacity:
		start_reload()

func start_reload():
	print("Reloading...")
	is_reloading = true
	is_locked = true
	reload_timer = reload_speed

func can_shoot() -> bool:
	return not is_locked and not is_reloading

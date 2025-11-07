extends Node

# Pool configuration
const INITIAL_POOL_SIZE = 50
const POOL_GROWTH_SIZE = 10
const MAX_POOL_SIZE = 200

# Animation settings
const FLOAT_DURATION = 1.0
const FLOAT_HEIGHT = 2.0
const FADE_START_TIME = 0.5
const POPUP_DURATION = 0.15
const POPUP_SCALE = .5

# Visual settings
const BASE_FONT_SIZE = 12
const CRITICAL_FONT_SIZE = 32
const Y_OFFSET = 2.0  # How far above the hit position to spawn

var pool: Array[Label3D] = []
var active_count = 0

func _ready():
	Global.dmg_num_pool = self
	
	# Pre-create initial pool
	for i in range(INITIAL_POOL_SIZE):
		_create_damage_number()


func show_heal(amount: int, position: Vector3, is_critical: bool = false) -> void:
	var label = _get_available_label()
	
	if label == null:
		# Pool exhausted, try to grow it
		if pool.size() < MAX_POOL_SIZE:
			for i in range(POOL_GROWTH_SIZE):
				_create_damage_number()
			label = _get_available_label()
		else:
			push_warning("Damage number pool at max capacity!")
			return
	
	# Configure the label
	label.text = str(amount)
	label.visible = true
	label.modulate = Color.WEB_GREEN
	label.font_size = CRITICAL_FONT_SIZE if is_critical else BASE_FONT_SIZE
	
	# Set color based on damage type
	if is_critical:
		label.modulate = Color.GREEN
	
	# Position above the hit location
	label.global_position = position
	label.scale = Vector3(0.5, 0.5, 0.5)
	
	active_count += 1
	
	# Animate
	_animate_damage_number(label)

func show_damage(amount: int, position: Vector3, is_critical: bool = false) -> void:
	var label = _get_available_label()
	
	if label == null:
		# Pool exhausted, try to grow it
		if pool.size() < MAX_POOL_SIZE:
			for i in range(POOL_GROWTH_SIZE):
				_create_damage_number()
			label = _get_available_label()
		else:
			push_warning("Damage number pool at max capacity!")
			return
	
	# Configure the label
	label.text = str(amount)
	label.visible = true
	label.modulate = Color.WHITE
	label.font_size = CRITICAL_FONT_SIZE if is_critical else BASE_FONT_SIZE
	
	# Set color based on damage type
	if is_critical:
		label.modulate = Color.ORANGE
	
	# Position above the hit location
	label.global_position = position + Vector3(0, Y_OFFSET, 0)
	label.scale = Vector3(0.5, 0.5, 0.5)
	
	active_count += 1
	
	# Animate
	_animate_damage_number(label)

func _create_damage_number() -> Label3D:
	var label = Label3D.new()
	
	# Configure Label3D properties
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.shaded = false
	label.double_sided = true
	label.no_depth_test = true  # Always visible, even through walls
	label.fixed_size = true
	label.font_size = BASE_FONT_SIZE
	label.font = load("uid://c5wg3k2lucri0")
	label.outline_size = 8
	label.outline_modulate = Color.BLACK
	
	label.visible = false
	add_child(label)
	pool.append(label)
	
	return label

func _get_available_label() -> Label3D:
	for label in pool:
		if not label.visible:
			return label
	return null

func _animate_damage_number(label: Label3D) -> void:
	var start_pos = label.global_position
	var end_pos = start_pos + Vector3(0, FLOAT_HEIGHT, 0)
	
	# Create tweens for animation
	var tween = create_tween()
	tween.set_parallel(true)  # All animations run simultaneously
	
	# Pop-in scale animation
	tween.tween_property(label, "scale", Vector3.ONE * POPUP_SCALE, POPUP_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	# Float upward
	tween.tween_property(label, "global_position", end_pos, FLOAT_DURATION)\
		.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	
	# Fade out (starts halfway through)
	tween.tween_property(label, "modulate:a", 0.0, FLOAT_DURATION - FADE_START_TIME)\
		.set_delay(FADE_START_TIME)
	
	# Scale down slightly as it fades
	tween.tween_property(label, "scale", Vector3.ONE * 0.8, FLOAT_DURATION - FADE_START_TIME)\
		.set_delay(FADE_START_TIME)
	
	# Return to pool when done
	tween.set_parallel(false)
	tween.tween_callback(func(): _return_to_pool(label))

func _return_to_pool(label: Label3D) -> void:
	label.visible = false
	label.modulate = Color.WHITE
	label.scale = Vector3.ONE
	active_count -= 1

# Debug function
func get_pool_stats() -> Dictionary:
	return {
		"total_size": pool.size(),
		"active": active_count,
		"available": pool.size() - active_count
	}

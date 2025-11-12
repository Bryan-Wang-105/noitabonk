# gold_added_label.gd (attached directly to Gold_Added_label node)
extends Label

var current_amount: int = 0
var idle_timer: float = 0.0
var idle_duration: float = 2.0
var fade_duration: float = 0.5
var is_fading: bool = false

# gold_added_label.gd
var active_tween: Tween = null

func _ready():
	modulate.a = 0.0  # Start invisible

func _process(delta):
	if is_fading or modulate.a == 0.0:
		return
	
	idle_timer += delta
	if idle_timer >= idle_duration:
		fade_out()

func show_gold_added(value: int):
	current_amount += value
	text = "+" + str(current_amount)
	
	# Reset idle timer and visibility
	idle_timer = 0.0
	is_fading = false
	modulate.a = 1.0
	
	# Pulse animation
	pulse()

func pulse():
	# Kill previous tween if still running
	if active_tween:
		active_tween.kill()
		
	active_tween = create_tween()
	active_tween.tween_property(self, "scale", Vector2(1.5, 1.5), 0.1).set_ease(Tween.EASE_OUT)
	active_tween.tween_property(self, "scale", Vector2(1.0, 1.0), 0.2).set_ease(Tween.EASE_IN_OUT)


func fade_out():
	is_fading = true
	
	if active_tween:
		active_tween.kill()
	
	active_tween = create_tween()
	active_tween.tween_property(self, "modulate:a", 0.0, fade_duration)
	active_tween.tween_callback(reset_label)

func reset_label():
	current_amount = 0
	text = ""

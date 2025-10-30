# Basic wand prototype (will add spell modifiers etc later)
class_name Spell

var name
var cast_delay
var damage
var modifier
var projectile_scene
var projectile_sound
var icon_path
var description

func activate():
	print("BOOM")

func get_spell_info():
	return [name, icon_path, damage, cast_delay, description]

extends RigidBody3D

@export var SPELL: Resource

var prompt = "Press [E] to pick up spell"


func get_prompt():
	return prompt

func interact():
	SpellLibrary.add_spell_auto(SPELL.new())
	print("SPELL ADDED")
	queue_free()

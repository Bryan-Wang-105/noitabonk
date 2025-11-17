extends Node

func _ready():
	Global.dmg_display = self

func flash_dmg(body, crit=false):
	if body is MeshInstance3D:
		_flash_mesh(body, crit)
	else:
		# Loop through all MeshInstance3D under Body
		for mesh in body.get_children():
			_flash_mesh_recursive(mesh,crit)

func _flash_mesh_recursive(node: Node, crit) -> void:
	# If it's a MeshInstance3D, flash it
	if node is MeshInstance3D:
		_flash_mesh(node, crit)
	
	# Recurse into children
	for child in node.get_children():
		_flash_mesh_recursive(child, crit)


func _flash_mesh(mesh: MeshInstance3D, crit) -> void:
	# Make sure each surface has a unique material
	var surface_count := mesh.mesh.get_surface_count()
	for i in range(surface_count):
		var mat = mesh.get_active_material(i)
		if mat == null:
			continue
		
		# Ensure we don't modify the import material
		if not mat.resource_local_to_scene:
			mat = mat.duplicate()
			mesh.set_surface_override_material(i, mat)

		# Apply white flash
		mat.emission_enabled = true
		
		var em_str
		var color
		
		if crit:
			print("CRITTING")
			color = Color(1.0, 1.0, 1.0, 1.0)
			em_str = 2.5
		else:
			color = Color(0.385, 0.385, 0.385, 1.0)
			em_str = 1
		
		mat.emission = color
		mat.emission_energy = em_str
	# Schedule reset after a brief time
	await get_tree().create_timer(0.12).timeout

	# Reset all surfaces
	for i in range(surface_count):
		var mat
		if mesh:
			mat = mesh.get_active_material(i)
			if mat:
				mat.emission_enabled = false

extends Node

func _ready():
	Global.dmg_display = self

func flash_dmg(body):
	if body is MeshInstance3D:
		_flash_mesh(body)
	else:
		# Loop through all MeshInstance3D under Body
		for mesh in body.get_children():
			_flash_mesh_recursive(mesh)

func _flash_mesh_recursive(node: Node) -> void:
	# If it's a MeshInstance3D, flash it
	if node is MeshInstance3D:
		_flash_mesh(node)
	
	# Recurse into children
	for child in node.get_children():
		_flash_mesh_recursive(child)


func _flash_mesh(mesh: MeshInstance3D) -> void:
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
		mat.emission = Color(1, 1, 1)
		mat.emission_energy = 2.5

	# Schedule reset after a brief time
	await get_tree().create_timer(0.12).timeout

	# Reset all surfaces
	for i in range(surface_count):
		var mat
		if mesh:
			mat = mesh.get_active_material(i)
			if mat:
				mat.emission_enabled = false

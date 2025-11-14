# FlameTrail.gd
extends GPUParticles3D

func _ready():
	_setup_particle_material()
	_setup_draw_material()

func _setup_particle_material():
	# Configure GPUParticles3D basic settings
	emitting = true
	amount = 80
	lifetime = 0.8
	explosiveness = 0.0
	randomness = 0.3
	visibility_aabb = AABB(Vector3(-5, -5, -5), Vector3(10, 10, 10))
	
	# Create and configure ParticleProcessMaterial
	var material = ParticleProcessMaterial.new()
	
	# Emission
	material.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_POINT
	
	# Direction (will be updated dynamically by parent)
	material.direction = Vector3(0, 0, 1)
	material.spread = 25.0
	
	# Initial velocity (will be updated dynamically by parent)
	material.initial_velocity_min = 2.0
	material.initial_velocity_max = 4.0
	
	# Gravity
	material.gravity = Vector3.ZERO
	
	# Damping (makes particles slow down over time)
	material.damping_min = 2.0
	material.damping_max = 3.0
	
	# Scale
	material.scale_min = 0.3
	material.scale_max = 0.6
	
	# Create scale curve (particles shrink over lifetime)
	var scale_curve = Curve.new()
	scale_curve.add_point(Vector2(0.0, 1.0))  # Start at full scale
	scale_curve.add_point(Vector2(1.0, 0.0))  # End at zero scale
	var scale_curve_texture = CurveTexture.new()
	scale_curve_texture.curve = scale_curve
	material.scale_curve = scale_curve_texture
	
	# Color gradient (yellow -> orange -> red transparent)
	var color_gradient = Gradient.new()
	color_gradient.add_point(0.0, Color(1.0, 1.0, 0.8, 1.0))  # Bright yellow/white
	color_gradient.add_point(0.3, Color(1.0, 0.7, 0.0, 1.0))  # Orange
	color_gradient.add_point(0.7, Color(1.0, 0.3, 0.0, 0.8))  # Red-orange
	color_gradient.add_point(1.0, Color(1.0, 0.0, 0.0, 0.0))  # Transparent red
	
	var gradient_texture = GradientTexture1D.new()
	gradient_texture.gradient = color_gradient
	material.color_ramp = gradient_texture
	
	# Apply the material
	process_material = material

func _setup_draw_material():
	# Create the visual material for particles
	var draw_mat = StandardMaterial3D.new()
	
	# Basic settings
	draw_mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	draw_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	draw_mat.blend_mode = BaseMaterial3D.BLEND_MODE_ADD  # Additive for glow
	draw_mat.cull_mode = BaseMaterial3D.CULL_DISABLED
	draw_mat.billboard_mode = BaseMaterial3D.BILLBOARD_ENABLED
	
	# Color - CHANGED TO ORANGE
	draw_mat.albedo_color = Color(1.0, 0.5, 0.0, 1.0)  # Orange base color
	
	# Emission for glow
	draw_mat.emission_enabled = true
	draw_mat.emission = Color(1.0, 0.4, 0.0)  # Orange glow
	draw_mat.emission_energy_multiplier = 3.0
	
	# Apply to draw pass
	draw_pass_1 = QuadMesh.new()
	draw_pass_1.material = draw_mat

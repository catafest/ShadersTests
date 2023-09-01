extends Node3D

@onready var spatial_shader_sphere_var : ShaderMaterial = $MeshInstance3D.get_active_material(0)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#spatial_shader_sphere_var.set_shader_parameter("var_height",randf_range(0.0,3.0))
	spatial_shader_sphere_var.set_shader_parameter("var_height",3.0)
	await get_tree().create_timer(3.0).timeout
	pass

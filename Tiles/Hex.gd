extends Spatial

var shader : SpatialMaterial

# Called when the node enters the scene tree for the first time.
func _ready():
	$hex/Cylinder.mesh = $hex/Cylinder.mesh.duplicate(true)
	shader = $hex/Cylinder.mesh.surface_get_material(0).duplicate()
	$hex/Cylinder.mesh.surface_set_material(0, shader)
	pass # Replace with function body.

func set_colour(colour):
	shader.albedo_color = colour

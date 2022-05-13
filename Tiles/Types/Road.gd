extends Spatial

var tile

func _ready():
	tile.set_colour(Color.lightseagreen)
	RoadNetwork.add_road(position())

func _exit_tree():
	RoadNetwork.remove_road(position())

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

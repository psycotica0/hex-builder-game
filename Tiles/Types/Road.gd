extends Spatial

var tile

func _ready():
	tile.set_colour(Color.lightseagreen)

func _exit_tree():
	disable()

func enable():
	RoadNetwork.add_road(position())

func disable():
	RoadNetwork.remove_road(position())

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

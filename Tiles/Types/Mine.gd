extends Spatial

const Requirement = preload("res://TaskManager/Requirement.gd")

var tile
var request

func _ready():
	tile.set_colour(Color.khaki)
	RoadNetwork.add_building(position())
	$Timer.start()

func _exit_tree():
	TaskManager.remove_pickup(request)
	RoadNetwork.remove_building(position())
	$Timer.stop()

func _on_Timer_timeout():
	request = Requirement.new()
	request.source = self
	request.base_priority = 1
	request.time_priority = 1
	TaskManager.add_pickup(request)

func complete(_req):
	$Timer.start()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

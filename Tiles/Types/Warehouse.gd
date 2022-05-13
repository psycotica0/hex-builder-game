extends Spatial

var tile

const Requirement = preload("res://TaskManager/Requirement.gd")

var open_spaces = []
var taken_spaces = []

func _ready():
	tile.set_colour(Color.lightgoldenrod)
	RoadNetwork.add_building(position())
	
	for i in range(10):
		make_open_space()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

func make_open_space():
	var request = Requirement.new()
	request.source = self
	request.base_priority = 0
	request.time_priority = 0
	TaskManager.add_dropoff(request)
	open_spaces.push_back(request)

func make_taken_space():
	var request = Requirement.new()
	request.source = self
	request.base_priority = 0
	request.time_priority = 0
	TaskManager.add_pickup(request)
	taken_spaces.push_back(request)

func complete(req):
	var idx = open_spaces.find(req)
	if idx > -1:
		open_spaces.remove(idx)
		make_taken_space()
		return
	
	idx = taken_spaces.find(req)
	if idx > -1:
		taken_spaces.remove(idx)
		make_open_space()

func _exit_tree():
	RoadNetwork.remove_building(position())
	for space in open_spaces:
		TaskManager.remove_dropoff(space)
	
	for space in taken_spaces:
		TaskManager.remove_pickup(space)

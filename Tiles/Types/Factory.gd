extends Spatial

var tile
const Bot = preload("res://Bot.tscn")
const Requirement = preload("res://TaskManager/Requirement.gd")
var requests = []

var in_progress_requests = []
var inventory = 0

func _ready():
	Market.connect("seeking_requests", self, "on_seeking_requests")
	tile.set_colour(Color.purple)
	RoadNetwork.add_building(position())
	make_bot()

func _exit_tree():
	Market.disconnect("seeking_requests", self, "on_seeking_requests")
	RoadNetwork.remove_building(position())
	for request in requests:
		TaskManager.remove_dropoff(request)
	$Timer.stop()

func _on_Timer_timeout():
	inventory -= 2
	make_bot()

func make_bot():
	var instance = Bot.instance()
	instance.position = position()
	instance.tile_position = position()
	get_tree().root.add_child(instance)
	TaskManager.add_bot(instance)
	
func complete(req):
	in_progress_requests.erase(req)
	inventory += 1
	if inventory >= 2:
		$Timer.start()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

class Request:
	var source
	var commodity = 0

	func benefit():
		return (1.0 - inverse_lerp(0, 20, TaskManager.number_of_bots)) * 100
	
	func position():
		return source.position()
	
	func accept():
		source.in_progress_requests.append(self)
	
	func complete():
		source.complete(self)
	
	func building():
		return source

func on_seeking_requests(generation):
	var n = 2 - (inventory + in_progress_requests.size())
	
	for _i in range(0, n):
		var r = Request.new()
		r.source = self
		generation.add_request(r)

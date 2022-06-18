extends Spatial

const Offer = preload("res://Market/Offer.gd")

var tile
var requests = []

var in_progress_requests = []
var inventory = 0
var offer

func _ready():
	tile.set_colour(Color.red)

func _exit_tree():
	disable()

func enable():
	Market.connect("seeking_requests", self, "on_seeking_requests")
	RoadNetwork.add_building(position())

func disable():
	Market.disconnect("seeking_requests", self, "on_seeking_requests")
	RoadNetwork.remove_building(position())
	for request in requests:
		TaskManager.remove_dropoff(request)
	$Timer.stop()

func _on_Timer_timeout():
	inventory -= 2
	offer = Offer.new()
	offer.commodity = 1
	offer.position = position()
	offer.connect("completed", self, "pickup")
	add_child(offer)

func should_be_idle():
	return offer or not $Timer.is_stopped()

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
		# Benefit to make 1s, minus processing time
		# Divided by 2 because I need 2 inputs to do it
		return (Market.get_benefit(1) - 1) / 2;
	
	func position():
		return source.position()
	
	func accept():
		source.in_progress_requests.append(self)
	
	func complete():
		source.complete(self)
	
	func building():
		return source

func on_seeking_requests(generation):
	if should_be_idle():
		return
	
	var n = 2 - (inventory + in_progress_requests.size())
	
	for _i in range(0, n):
		var r = Request.new()
		r.source = self
		generation.add_request(r)

func pickup(req):
	offer = false

extends Spatial

var tile
#const Bot = preload("res://Bot.tscn")
const Requirement = preload("res://TaskManager/Requirement.gd")
var requests = []

var in_progress_requests = []
var inventory = 0
var produced = false

func _ready():
	tile.set_colour(Color.red)

func _exit_tree():
	disable()

func enable():
	Market.connect("seeking_requests", self, "on_seeking_requests")
	Market.connect("seeking_offers", self, "on_seeking_offers")
	RoadNetwork.add_building(position())

func disable():
	Market.disconnect("seeking_requests", self, "on_seeking_requests")
	Market.disconnect("seeking_offers", self, "on_seeking_offers")
	RoadNetwork.remove_building(position())
	for request in requests:
		TaskManager.remove_dropoff(request)
	$Timer.stop()

func _on_Timer_timeout():
	inventory -= 2
	produced = 1
#	make_bot()

func should_be_idle():
	return produced or not $Timer.is_stopped()

#func make_bot():
#	var instance = Bot.instance()
#	instance.position = position()
#	instance.tile_position = position()
#	get_tree().root.add_child(instance)
#	TaskManager.add_bot(instance)
	
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

class Offer:
	var dropoff
	var pickup
	var generation
	
	func accept():
		pickup.in_progress_requests.append(self)
		dropoff.accept()
	
	func complete():
		dropoff.complete()
	
	func start():
		pickup.pickup(self)
		
	func commodity():
		return dropoff.commodity
		
	func benefit():
		var benefit = dropoff.benefit() #generation.get_benefit(0)
		var path = RoadNetwork.path_length(pickup.position(), dropoff.position())
		
		if path == 0:
			return 0
		else:
			return benefit - path
	
	func building():
		return pickup
		
func pickup(req):
	in_progress_requests.erase(req)
	produced = false

func on_seeking_offers(generation):
	if not in_progress_requests.empty() or not produced:
		return
	
	for request in generation.get_requests(1):
		var offer = Offer.new()
		offer.generation = generation
		offer.dropoff = request
		offer.pickup = self
		generation.add_offer(offer)

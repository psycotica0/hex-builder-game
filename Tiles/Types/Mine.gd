extends Spatial

const Requirement = preload("res://TaskManager/Requirement.gd")

var tile
var accepted_request
var inventory = 0

func _ready():
	tile.set_colour(Color.khaki)

func _exit_tree():
	disable()

func enable():
	Market.connect("seeking_offers", self, "on_seeking_offers")
	RoadNetwork.add_building(position())
	$Timer.start()

func disable():
	Market.disconnect("seeking_offers", self, "on_seeking_offers")
	RoadNetwork.remove_building(position())
	$Timer.stop()

func _on_Timer_timeout():
	inventory += 1

func complete(_req):
	inventory -= 1
	accepted_request = null
	$Timer.start()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

class Offer:
	var dropoff
	var pickup
	var generation
	
	func accept():
		pickup.accepted_request = self
		dropoff.accept()
	
	func complete():
		dropoff.complete()
	
	func start():
		pickup.complete(self)
		
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

func on_seeking_offers(generation):
	if inventory == 0 or accepted_request:
		return
	
	for request in generation.get_requests(0):
		var offer = Offer.new()
		offer.generation = generation
		offer.dropoff = request
		offer.pickup = self
		generation.add_offer(offer)

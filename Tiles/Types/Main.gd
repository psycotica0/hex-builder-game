extends Spatial

var tile
var accepted_request
var inventory = 0

const INITIAL_BOTS = 4

const Bot = preload("res://Bot.tscn")

func _ready():
	Market.connect("seeking_offers", self, "on_seeking_offers")
	tile.set_colour(Color.white)
	RoadNetwork.add_building(position())
	$Timer.start()
	
	for _i in range(INITIAL_BOTS):
		make_bot()

func _exit_tree():
	Market.disconnect("seeking_offers", self, "on_seeking_offers")
	RoadNetwork.remove_building(position())
	$Timer.stop()

func _on_Timer_timeout():
	inventory += 1

func make_bot():
	var instance = Bot.instance()
	instance.position = position()
	if Flags.DEBUG_BOT_LOCATION:
		get_tree().root.add_child(instance)
	TaskManager.add_bot(instance)

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

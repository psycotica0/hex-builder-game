extends Spatial

var tile

var goals = {
	0: 7
}

class Request:
	var source
	var commodity = 0
	var pressure
	
	func _init(s, p):
		source = s
		pressure = p

	func benefit():
		return pressure
	
	func position():
		return source.position()
	
	func accept():
		source.accepted_task = self
	
	func complete():
		source.dropoff(self)
	
	func building():
		return source.building()

class Offer:
	var dropoff
	var pickup
	var generation
	var pressure
	
	func accept():
		pickup.accepted_task = self
		dropoff.accept()
	
	func complete():
		dropoff.complete()
	
	func start():
		pickup.pickup()
		
	func commodity():
		return dropoff.commodity
		
	func benefit():
		var benefit = dropoff.benefit() - pressure
		var path = RoadNetwork.path_length(pickup.position(), dropoff.position())
		
		if path == 0:
			return 0
		else:
			return benefit - path
	
	func building():
		return pickup.building()

class Slot:
	var filled = false
	var commodity
	var holder
	var accepted_task
	
	func _init(h):
		holder = h
	
	func on_seeking_offers_with_pressure(generation, pressure):
		if (not filled) or accepted_task:
			return
		
		for request in generation.get_requests(commodity):
			if request.building() == building():
				continue
			
			var offer = Offer.new()
			offer.generation = generation
			offer.dropoff = request
			offer.pickup = self
			offer.pressure = pressure[commodity]
			generation.add_offer(offer)
	
	func on_seeking_requests_with_pressure(generation, pressure):
		if filled or accepted_task:
			return
		
		for commodity in pressure:
			generation.add_request(Request.new(self, pressure[commodity]))
	
	func pickup():
		filled = false
		accepted_task = null
	
	func dropoff(req):
		filled = true
		commodity = req.commodity
		accepted_task = null
	
	func position():
		return holder.position()
	
	func building():
		return holder

var slots = []

func _ready():
	tile.set_colour(Color.lightgoldenrod)
	
	for i in range(10):
		slots.append(Slot.new(self))

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

func _exit_tree():
	disable()

func enable():
	Market.connect("seeking_offers", self, "on_seeking_offers")
	Market.connect("seeking_requests", self, "on_seeking_requests")
	
	RoadNetwork.add_building(position())

func disable():
	Market.disconnect("seeking_offers", self, "on_seeking_offers")
	Market.disconnect("seeking_requests", self, "on_seeking_requests")
	RoadNetwork.remove_building(position())

func generate_offer_pressure(generation):
	var counts = {}
	for slot in slots:
		if slot.filled:
			if counts.has(slot.commodity):
				counts[slot.commodity] += 1
			else:
				counts[slot.commodity] = 1
	
	for commodity in goals:
		counts[commodity] = (1.0 - inverse_lerp(0, goals[commodity], counts.get(commodity, 0.0))) * 100
	
	return counts

func on_seeking_offers(generation):
	var pressure = generate_offer_pressure(generation)
	for slot in slots:
		slot.on_seeking_offers_with_pressure(generation, pressure)

func on_seeking_requests(generation):
	var pressure = generate_offer_pressure(generation)
	for slot in slots:
		slot.on_seeking_requests_with_pressure(generation, pressure)

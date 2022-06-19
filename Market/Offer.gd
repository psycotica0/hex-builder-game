extends Node

export (Dictionary) var price_sheet
export var accepted = false
export (int) var exclusive_id = 0
export (int) var commodity
export (Vector2) var position

signal accepted(task)
signal completed(task)

func _init():
	._init()
	name = "Offer"

func _ready():
	Market.connect("seeking_offers", self, "on_seeking_offers")
	if not price_sheet:
		price_sheet = {}

func _exit_tree():
	Market.disconnect("seeking_offers", self, "on_seeking_offers")

func on_seeking_offers(generation):
	if accepted:
		return
	
	for request in generation.get_requests(commodity):
		if request.position == position:
			continue
		
		var offer = Proposal.new()
		offer.generation = generation
		offer.dropoff = request
		offer.pickup = self
		offer.keep_benefit = price_sheet.get(commodity, 0.0)
		generation.add_offer(offer)

func complete(_proposal):
	emit_signal("completed", self)
	get_parent().remove_child(self)
	queue_free()

func accept(_proposal):
	accepted = true
	emit_signal("accepted", self)

func debug_name():
	return "%s" % get_node("/root/Level").get_path_to(self)

class Proposal:
	var dropoff
	var pickup
	var generation
	var keep_benefit
	
	func accept():
		pickup.accept(self)
		dropoff.accept()
	
	func complete():
		dropoff.complete()
	
	func start():
		pickup.complete(self)
		
	func commodity():
		return dropoff.commodity
		
	func benefit():
		var total = dropoff.benefit()
		var path = RoadNetwork.path_length(pickup.position, dropoff.position)
		
		if path == 0:
			return 0
		else:
			return total - keep_benefit - path
	
	func _to_string():
		return "%s -> %s: %f" % [pickup.debug_name(), dropoff, benefit()]

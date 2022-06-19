extends Node

var Generation = load("res://Market/Generation.gd")

signal seeking_requests(generation)
signal generate_prices(generation)
signal seeking_offers(generation)

var current_generation

func _ready():
	pass

func get_offers():
	if Flags.DEBUG_OFFERS != Flags.NONE:
		prints("\nMarket")
	
	current_generation = Generation.new()
	emit_signal("seeking_requests", current_generation)
	
	if Flags.DEBUG_OFFERS & Flags.REQUEST_LIST:
		prints("<< REQUESTS")
		for request in current_generation.get_all_requests():
			prints("REQUEST", request, ":", request.benefit())
		prints(">> REQUESTS")
	
	emit_signal("generate_prices", current_generation)
	emit_signal("seeking_offers", current_generation)
	
	if Flags.DEBUG_OFFERS & Flags.ORDER_LIST:
		prints("<< ORDERS")
		for offer in current_generation.get_offers():
			prints("Offer", offer)
#			prints("Offer", offer.building().get_path(), "->", offer.dropoff.building().get_path(), ":", offer.benefit())
		prints(">> ORDERS")
	
	return current_generation.get_offers()

func get_benefit(commodity):
	assert(current_generation)
	
	return current_generation.get_benefit(commodity)

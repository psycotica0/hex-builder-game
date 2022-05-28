extends Reference

const Commodity = preload("res://Market/Commodity.gd")

var DEBUG_OFFERS = false

var requests = {}
var offers = []

func add_request(request):
	var commodity_market
	if requests.has(request.commodity):
		commodity_market = requests[request.commodity]
	else:
		commodity_market = Commodity.new()
		requests[request.commodity] = commodity_market
	
	commodity_market.add_request(request)

func add_offer(offer):
	if offer.benefit() > 0:
		var idx = offers.bsearch_custom(offer, self, "offer_sort")
		offers.insert(idx, offer)

func offer_sort(a, b):
	return a.benefit() > b.benefit()

func get_requests(commodity):
	if not requests.has(commodity):
		return []
	return requests[commodity].requests()

func get_offers():
	if DEBUG_OFFERS:
		prints("TOP")
		for offer in offers:
			prints("Offer", offer.building().get_path(), "->", offer.dropoff.building().get_path(), ":", offer.benefit())
	return offers

func get_benefit(commodity):
	if requests.has(commodity):
		return requests[commodity].benefit()
	else:
		return 0

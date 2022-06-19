extends Spatial

const Offer = preload("res://Market/Offer.gd")
const Request = preload("res://Market/Request.gd")
const Slot = preload("res://Slot.gd")

var tile

var price_sheet = {}
var slot = Slot.new()

func _ready():
	tile.set_colour(Color.red)
	add_child(slot, true)
	slot.connect("request_empty", self, "on_request_empty")
	slot.connect("offer_empty", self, "on_offer_empty")

func _exit_tree():
	disable()

func enable():
	Market.connect("generate_prices", self, "on_generate_prices")
	RoadNetwork.add_building(position())
	make_requests()

func disable():
	Market.disconnect("generate_prices", self, "on_generate_prices")
	RoadNetwork.remove_building(position())
	$Timer.stop()

func _on_Timer_timeout():
	var offer = Offer.new()
	offer.commodity = 1
	offer.position = position()
	slot.add_child(offer, true)

func on_generate_prices(generation):
	# Benefit to make 1s, minus processing time
	# Divided by 2 because I need 2 inputs to do it
	price_sheet[0] = (generation.get_benefit(1) - 1) / 2

func on_request_empty():
	$Timer.start()

func on_offer_empty():
	make_requests()

func make_requests():
	for _i in range(2):
		var req = Request.new()
		req.price_sheet = price_sheet
		req.commodity = 0
		req.position = position()
		slot.add_child(req, true)

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

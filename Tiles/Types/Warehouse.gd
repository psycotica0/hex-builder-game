extends Spatial

const Offer = preload("res://Market/Offer.gd")
const Request = preload("res://Market/Request.gd")
const Slot = preload("res://Slot.gd")

var tile

var goals = {
	0: 7
}

var inventory = {}

var price_sheet = {}

func _ready():
	tile.set_colour(Color.lightgoldenrod)
	
	for commodity in goals:
		inventory[commodity] = 0
	
	for _i in range(10):
		var slot = Slot.new()
		add_requests(slot)
		add_child(slot, true)

func add_requests(slot):
	for commodity in goals:
		var request = Request.new()
		request.price_sheet = price_sheet
		request.commodity = commodity
		request.position = position()
		request.connect("completed", self, "on_request_completed", [slot])
		# Only one request from this slot can be done at a time
		request.exclusive_id = slot.get_instance_id()
		slot.add_child(request, true)

func on_offer_completed(offer, slot):
	inventory[offer.commodity] -= 1
	add_requests(slot)

func on_request_completed(request, slot):
	inventory[request.commodity] += 1
	
	var offer = Offer.new()
	offer.commodity = request.commodity
	offer.position = position()
	offer.price_sheet = price_sheet
	offer.connect("completed", self, "on_offer_completed", [slot])
	
	# Remove any other requests, this slot is now full
	for child in slot.get_children():
		# The request will remove itself
		if child != request:
			slot.remove_child(child)
	
	slot.add_child(offer, true)

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

func _exit_tree():
	disable()

func enable():
	Market.connect("generate_prices", self, "generate_prices")
	
	RoadNetwork.add_building(position())

func disable():
	Market.disconnect("generate_prices", self, "generate_prices")
	RoadNetwork.remove_building(position())

func generate_prices(_generation):
	for commodity in goals:
		price_sheet[commodity] = (1.0 - inverse_lerp(0, goals[commodity], inventory.get(commodity, 0))) * 100

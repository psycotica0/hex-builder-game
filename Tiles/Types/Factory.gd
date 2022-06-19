extends Spatial

var tile

const Bot = preload("res://Bot.tscn")
const Request = preload("res://Market/Request.gd")
const Slot = preload("res://Slot.gd")

var price_sheet = {}
var slot = Slot.new()

func _ready():
	tile.set_colour(Color.purple)
	add_child(slot, true)
	slot.connect("request_empty", self, "on_slot_empty")

func _exit_tree():
	disable()

func enable():
	Market.connect("generate_prices", self, "on_generate_prices")
	make_requests()
	RoadNetwork.add_building(position())

func disable():
	Market.disconnect("generate_prices", self, "on_generate_prices")
	RoadNetwork.remove_building(position())
	$Timer.stop()

func make_requests():
	for _i in range(2):
		var req = Request.new()
		req.price_sheet = price_sheet
		req.commodity = 1
		req.position = position()
		slot.add_child(req, true)

func _on_Timer_timeout():
	make_bot()
	make_requests()

func on_slot_empty():
	$Timer.start()

func make_bot():
	var instance = Bot.instance()
	instance.position = position()
	if Flags.DEBUG_BOT_LOCATION:
		get_tree().root.add_child(instance)
	TaskManager.add_bot(instance)

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

func on_generate_prices(generation):
	price_sheet[1] = (1.0 - inverse_lerp(0, 20, TaskManager.number_of_bots)) * 100

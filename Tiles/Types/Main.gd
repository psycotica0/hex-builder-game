extends Spatial

var tile

const INITIAL_BOTS = 4

const Bot = preload("res://Bot.tscn")
const Offer = preload("res://Market/Offer.gd")

func _ready():
	tile.set_colour(Color.white)
	enable()
	
	for _i in range(INITIAL_BOTS):
		make_bot()

func _exit_tree():
	disable()

func enable():
	RoadNetwork.add_building(position())
	$Timer.start()

func disable():
	RoadNetwork.remove_building(position())
	$Timer.stop()

func _on_Timer_timeout():
	var offer = Offer.new()
	offer.commodity = 0
	offer.position = position()
	offer.connect("completed", self, "complete")
	add_child(offer)

func make_bot():
	var instance = Bot.instance()
	instance.position = position()
	if Flags.DEBUG_BOT_LOCATION:
		get_tree().root.add_child(instance)
	TaskManager.add_bot(instance)

func complete(_req):
	$Timer.start()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

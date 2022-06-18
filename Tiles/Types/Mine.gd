extends Spatial

const Offer = preload("res://Market/Offer.gd")

var tile

func _ready():
	tile.set_colour(Color.khaki)

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

func complete(_req):
	$Timer.start()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

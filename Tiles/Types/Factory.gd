extends Spatial

var tile
const Bot = preload("res://Bot.tscn")
const Requirement = preload("res://TaskManager/Requirement.gd")
var requests = []

func _ready():
	tile.set_colour(Color.purple)
	make_bot()

func _exit_tree():
	for request in requests:
		TaskManager.remove_dropoff(request)
	$Timer.stop()

func _on_Timer_timeout():
	make_bot()

func make_bot():
	var instance = Bot.instance()
	instance.position = position()
	get_tree().root.add_child(instance)
	TaskManager.add_bot(instance)
	
	for i in range(10):
		var request = Requirement.new()
		request.source = self
		request.base_priority = 1
		request.time_priority = 1
		TaskManager.add_dropoff(request)
		requests.push_back(request)
	
func complete(req):
	requests.erase(req)
	if requests.empty():
		$Timer.start()

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

extends Spatial

var DEBUG_PATHS = true

var speed = 1

var index
var progress = 0.0
var position
#var tile_position
var current_task
var inventory
var path = []

enum STATE {IDLE, STARTING, DOING}
var current_state = STATE.IDLE

func assign(offer):
	current_task = offer
	current_task.accept()
	current_state = STATE.STARTING
	var p = RoadNetwork.find_path(position, offer.pickup.position())
	p.append_array(RoadNetwork.find_path(offer.pickup.position(), offer.dropoff.position()))
	path = Array(p)
	progress = 0.0
	if DEBUG_PATHS:
		prints("Assigned", index, position, path)
	position = path.pop_front()

func compute_cost(offer):
	var p = RoadNetwork.find_path(position, offer.pickup.position())
	if p.empty():
		return -1
	else:
		return p.size()

func _physics_process(_delta):
	global_transform.origin.x = position.x
	global_transform.origin.z = position.y

func progress(delta):
	if current_state == STATE.IDLE:
		return true
	
	if path.empty():
		current_state = STATE.IDLE
		return true
	
	progress += delta * speed;
	
	if progress > 1.0:
		position = path.pop_front()
		progress -= 1.0;
		if current_state == STATE.STARTING and position == current_task.pickup.position():
			inventory = current_task.commodity()
			current_task.start()
			current_state = STATE.DOING
		elif current_state == STATE.DOING and position == current_task.dropoff.position():
			inventory = null
			current_task.complete()
			current_state = STATE.IDLE
			return true
	
	return false

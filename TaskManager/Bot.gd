extends Spatial

var speed = 1

var position
var tile_position
var current_task
var inventory
var path = []

enum STATE {IDLE, STARTING, DOING}
var current_state = STATE.IDLE

func assign(offer):
	current_task = offer
	current_task.accept()
	current_state = STATE.STARTING
	var p = RoadNetwork.find_path(tile_position, offer.pickup.position())
	p.append_array(RoadNetwork.find_path(offer.pickup.position(), offer.dropoff.position()))
	path = Array(p)

func compute_cost(offer):
	var p = RoadNetwork.find_path(tile_position, offer.pickup.position())
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
	
	var goal = path[0]
	
	if position.distance_to(goal) < delta * speed:
		path.pop_front()
		position = goal
		tile_position = goal
		if current_state == STATE.STARTING and goal == current_task.pickup.position():
			inventory = current_task.commodity()
			current_task.start()
			current_state = STATE.DOING
		elif current_state == STATE.DOING and goal == current_task.dropoff.position():
			inventory = null
			current_task.complete()
			current_state = STATE.IDLE
			return true
	else:
		position = position.move_toward(goal, delta * speed)
	
	return false

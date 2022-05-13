extends Spatial

var speed = 1

var position
var tile_position
var current_task
var inventory
var path = []

enum STATE {IDLE, STARTING, DOING}
var current_state = STATE.IDLE

func assign(task):
	current_task = task
	current_state = STATE.STARTING
	var p = RoadNetwork.find_path(tile_position, task.source.position())
	p.append_array(RoadNetwork.find_path(task.source.position(), task.destination.position()))
	path = Array(p)

func compute_cost(task):
	var p = RoadNetwork.find_path(tile_position, task.source.position())
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
		if current_state == STATE.STARTING and goal == current_task.source.position():
			inventory = current_task.source.resource
			current_task.source.complete()
			current_state = STATE.DOING
		elif current_state == STATE.DOING and goal == current_task.destination.position():
			inventory = null
			current_task.destination.complete()
			current_state = STATE.IDLE
			return true
	else:
		position = position.move_toward(goal, delta * speed)
	
	return false

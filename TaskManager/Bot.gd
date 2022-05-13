extends Spatial

var speed = 1

var position
var current_task
var inventory

enum STATE {IDLE, STARTING, DOING}
var current_state = STATE.IDLE

func assign(task):
	current_task = task
	current_state = STATE.STARTING

func compute_cost(task):
	return position.distance_to(task.source.position())

func _physics_process(_delta):
	global_transform.origin.x = position.x
	global_transform.origin.z = position.y

func progress(delta):
	if current_state == STATE.IDLE:
		return true
	
	var goal
	if current_state == STATE.STARTING:
		goal = current_task.source.position()
	else:
		goal = current_task.destination.position()
	
	if position.distance_to(goal) < delta * speed:
		position = goal
		if current_state == STATE.STARTING:
			inventory = current_task.source.resource
			current_task.source.complete()
			current_state = STATE.DOING
		else:
			inventory = null
			current_task.destination.complete()
			current_state = STATE.IDLE
			return true
	else:
		position = position.move_toward(goal, delta * speed)
	
	return false

extends Node

const Task = preload("res://TaskManager/Task.gd")

var open_pickups = []
var open_dropoffs = []

var working_bots = []
var idle_bots = []

# TODO: Open question, how do I want to handle an interrupted task such that I have a bot that's holding something but can no longer complete the task it's been given

func add_pickup(pickup):
	open_pickups.append(pickup)

func remove_pickup(pickup):
	# XXX: These should cancel in-progress tasks too
	open_pickups.erase(pickup)

func add_dropoff(dropoff):
	open_dropoffs.append(dropoff)

func remove_dropoff(dropoff):
	# XXX: These should cancel in-progress tasks too
	open_dropoffs.erase(dropoff)

func add_bot(bot):
	idle_bots.append(bot)

func _process(delta):
	open_pickups.sort_custom(self, "priority_sort")
	open_dropoffs.sort_custom(self, "priority_sort")
	
	make_matches()
	for bot in working_bots:
		if bot.progress(delta):
			working_bots.erase(bot)
			idle_bots.append(bot)

func make_matches():
	var maybe_pickups = open_pickups.duplicate()
	var maybe_dropoffs = open_dropoffs.duplicate()
	
	# I may want to find the highest value combination of pickups and dropoffs
	# But that may lead to starvation of a high-value pickup if there's no high-value drop-offs
	# But... maybe that's more right? Unsure.
	while not (idle_bots.empty() or maybe_pickups.empty() or maybe_dropoffs.empty()):
		if maybe_pickups[0].priority() > maybe_dropoffs[0].priority():
			var try = maybe_pickups.pop_front()
			for dropoff in maybe_dropoffs:
				if dropoff.matches(try):
					var task = Task.new(try, dropoff)
					if assign_bot_to_task(task):
						maybe_dropoffs.erase(dropoff)
						open_pickups.erase(try)
						open_dropoffs.erase(dropoff)
						break
		else:
			var try = maybe_dropoffs.pop_front()
			for pickup in maybe_pickups:
				if pickup.matches(try):
					var task = Task.new(pickup, try)
					if assign_bot_to_task(task):
						maybe_pickups.erase(pickup)
						open_pickups.erase(pickup)
						open_dropoffs.erase(try)
						break

func assign_bot_to_task(task):
	var best
	# I didn't want to think about edge cases, and this should be plenty big
	var best_value = 2^62
	
	for bot in idle_bots:
		var value = bot.compute_cost(task)
		if value > -1 and value < best_value:
			best = bot
			best_value = value
	
	if best == null:
		return false
	
	best.assign(task)
	idle_bots.erase(best)
	working_bots.append(best)
	return true
	
func priority_sort(one, two):
	if one.priority() > two.priority():
		return true
	else:
		return false

extends Node

var working_bots = []
var idle_bots = []

# This operates as a set, but since I have to put something at the key it may
# as well be the object holding the lock
var exclusive_ids = {}

var number_of_bots = 0

var level

# TODO: Open question, how do I want to handle an interrupted task such that I have a bot that's holding something but can no longer complete the task it's been given

func add_bot(bot):
	bot.index = number_of_bots
	number_of_bots += 1
	idle_bots.append(bot)
	level.set_bot_state(bot.index, bot.position.x, bot.position.y, 1.0)

func _process(delta):
	make_matches()
	for bot in working_bots:
		if bot.progress(delta):
			working_bots.erase(bot)
			idle_bots.append(bot)
		var state = 1.0
		if bot.inventory != null:
			state += bot.inventory + 1;
		level.set_bot_state(bot.index, bot.position.x, bot.position.y, state)

func make_matches():
	if idle_bots.empty():
		return
	
	# These are the things we're assigning in this round
	# But they aren't globally unique, just unique for this batch
	var taken_objs = {}
	
	for offer in Market.get_offers():
		if idle_bots.empty():
			break
		
		var pick = offer.pickup
		var drop = offer.dropoff.source
		
		if pick.exclusive_id != 0:
			if exclusive_ids.has(pick.exclusive_id):
				continue
		else:
			if taken_objs.has(pick.get_instance_id()):
				continue
		
		if drop.exclusive_id != 0:
			if exclusive_ids.has(drop.exclusive_id):
				continue
		else:
			if taken_objs.has(drop.get_instance_id()):
				continue
		
		var bot = bot_for_offer(offer)
		if not bot:
			continue
		
		if pick.exclusive_id != 0:
			var i = pick.exclusive_id
			exclusive_ids[i] = offer
			pick.connect("completed", self, "release_exclusive", [i])
		else:
			taken_objs[pick.get_instance_id()] = offer
		
		if drop.exclusive_id != 0:
			var i = drop.exclusive_id
			exclusive_ids[i] = offer
			drop.connect("completed", self, "release_exclusive", [i])
		else:
			taken_objs[drop.get_instance_id()] = offer
		
		bot.assign(offer)
		working_bots.append(bot)
		idle_bots.erase(bot)

func bot_for_offer(offer):
	var best
	# I didn't want to think about edge cases, and this should be plenty big
	var best_value = 2^62
	
	for bot in idle_bots:
		var value = bot.compute_cost(offer)
		if value > -1 and value < best_value:
			best = bot
			best_value = value
	
	return best

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

func release_exclusive(_thing, id):
	exclusive_ids.erase(id)

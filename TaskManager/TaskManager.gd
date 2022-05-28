extends Node

const Task = preload("res://TaskManager/Task.gd")

var working_bots = []
var idle_bots = []

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
		level.set_bot_state(bot.index, bot.position.x, bot.position.y, 1.0)

func make_matches():
	if idle_bots.empty():
		return
	
	var taken_pickups = []
	var taken_dropoffs = []
	
	for offer in Market.get_offers():
		if idle_bots.empty():
			break
		
		if taken_pickups.has(offer.pickup):
			continue
		
		if taken_dropoffs.has(offer.dropoff):
			continue
		
		var bot = bot_for_offer(offer)
		if not bot:
			continue
		
		taken_pickups.append(offer.pickup)
		taken_dropoffs.append(offer.dropoff)
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

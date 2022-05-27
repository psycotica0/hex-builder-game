extends Node

var Generation = load("res://Market/Generation.gd")

signal seeking_requests(generation)
signal seeking_offers(generation)

var current_generation

func _ready():
	pass

func get_offers():
	current_generation = Generation.new()
	emit_signal("seeking_requests", current_generation)
	emit_signal("seeking_offers", current_generation)
	
	return current_generation.get_offers()

func get_benefit(commodity):
	assert(current_generation)
	
	return current_generation.get_benefit(commodity)

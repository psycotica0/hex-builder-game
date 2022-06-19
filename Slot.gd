extends Node

const Offer = preload("res://Market/Offer.gd")
const Request = preload("res://Market/Request.gd")

signal offer_empty
signal request_empty

func _init():
	._init()
	name = "Slot"

func add_child(child, legible_unique_name: bool = false):
	.add_child(child, legible_unique_name)
	if child is Offer:
		child.connect("completed", self, "complete_offer")
	elif child is Request:
		child.connect("completed", self, "complete_request")

func complete_offer(_x):
	yield(get_tree(), "idle_frame")
	var found = false
	for child in get_children():
		if child is Offer:
			found = true
			break
	
	if not found:
		emit_signal("offer_empty")

func complete_request(_x):
	yield(get_tree(), "idle_frame")
	var found = false
	for child in get_children():
		if child is Request:
			found = true
			break
	
	if not found:
		emit_signal("request_empty")

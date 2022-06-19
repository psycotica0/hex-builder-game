extends Node

export (Dictionary) var price_sheet
export var accepted = false
export (int) var exclusive_id = 0
export (int) var commodity
export (Vector2) var position

signal accepted(task)
signal completed(task)

func _init():
	._init()
	name = "Request"

func _ready():
	Market.connect("seeking_requests", self, "on_seeking_requests")

func _exit_tree():
	Market.disconnect("seeking_requests", self, "on_seeking_requests")

func on_seeking_requests(generation):
	if accepted:
		return
	
	var request = Request.new()
	request.source = self
	request.commodity = commodity
	request.price_sheet = price_sheet
	request.position = position
	generation.add_request(request)

func complete(_proposal):
	emit_signal("completed", self)
	get_parent().remove_child(self)
	queue_free()

func accept(_proposal):
	accepted = true
	emit_signal("accepted", self)

func debug_name():
	return "%s" % get_node("/root/Level").get_path_to(self)

class Request:
	var source
	var commodity
	var price_sheet
	var position

	func benefit():
		return price_sheet.get(commodity, 0.0)
	
	func accept():
		source.accept(self)
	
	func complete():
		source.complete(self)
	
	func _to_string():
		return "%s(%d)" % [source.debug_name(), commodity]

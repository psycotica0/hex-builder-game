extends Resource

class Component:
	var commodity
	var amount
	
	func price():
		return Market.price_for(commodity) * amount

class Time:
	var x

var components = []

func _ready():
	pass

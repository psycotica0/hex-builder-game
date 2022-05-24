extends Resource

var object
var price_method
var commodity

func _init(commodity, obj, meth):
	object = obj
	price_method = meth

func price():
	return object.call(price_method)

func location():
	return object.location()

func redeem():
	object.redeem(self)

extends Area

class_name BaseTile

const Slot = preload("res://Slot.gd")
const Request = preload("res://Market/Request.gd")

const BOUNCE = 1.0 / 16

enum SELECT_STATE { NONE, HOVER, SELECTED }
var select_state = SELECT_STATE.NONE

var current_type
var construction = false
var building
var price_sheet = {
	0: 50.0
}

# Called when the node enters the scene tree for the first time.
func _ready():
	set_colour(null)

func set_colour(colour):
	if colour:
		$Holder/Hex.set_colour(colour)
	else:
		$Holder/Hex.set_colour(Color.paleturquoise)

func set_select_state(s):
	select_state = s
	match s:
		SELECT_STATE.NONE:
			$Holder.translation.y = 0
		SELECT_STATE.HOVER:
			$Holder.translation.y = BOUNCE
		SELECT_STATE.SELECTED:
			$Holder.translation.y = 2 * BOUNCE

func hover():
	if select_state == SELECT_STATE.NONE:
		set_select_state(SELECT_STATE.HOVER)

func unhover():
	if select_state == SELECT_STATE.HOVER:
		set_select_state(SELECT_STATE.NONE)

func select():
	if select_state != SELECT_STATE.SELECTED:
		set_select_state(SELECT_STATE.SELECTED)

func deselect():
	if select_state == SELECT_STATE.SELECTED:
		set_select_state(SELECT_STATE.NONE)

func menus():
	var base = preload("res://Screens/BaseTileMenu.tscn")
	var empty = preload("res://Screens/EmptyTileMenu.tscn")
	
	if construction:
		return [base]
	elif current_type:
		return [base]
	else:
		return [base, empty]

func build(type):
	construction = true
	$Holder/Construction.visible = true
	
	if Flags.FREE_CONSTRUCTION:
		construction_paid(null)
	else:
		var slot = Slot.new()
		for _i in range(3):
			var r = Request.new()
			r.commodity = 0
			r.price_sheet = price_sheet
			r.position = position()
			slot.add_child(r, true)
		slot.connect("request_empty", self, "construction_paid", [slot])
		add_child(slot, true)
		RoadNetwork.add_building(position())
	
	set_type(type)

func position():
	var o = global_transform.origin
	return Vector2(o.x, o.z)

func construction_paid(slot):
	if slot:
		remove_child(slot)
		slot.queue_free()
	RoadNetwork.remove_building(position())
	$Timer.start()

func set_type(type):
	for c in $Holder/Type.get_children():
		$Holder/Type.remove_child(c)
		set_colour(null)
	
	current_type = type
	building = type.instance()
	building.tile = self
	$Holder/Type.add_child(building)

func _on_Timer_timeout():
	$Holder/Construction.visible = false
	construction = false
	building.enable()

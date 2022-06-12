extends Area

class_name BaseTile

const BOUNCE = 1.0 / 16

enum SELECT_STATE { NONE, HOVER, SELECTED }
var select_state = SELECT_STATE.NONE

var current_type

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
	
	if current_type:
		return [base]
	else:
		return [base, empty]

func set_type(type):
	for c in $Holder/Type.get_children():
		$Holder/Type.remove_child(c)
		set_colour(null)
	
	current_type = type
	var building = type.instance()
	building.tile = self
	$Holder/Type.add_child(building)

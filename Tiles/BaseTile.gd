extends Area

const BOUNCE = 1.0 / 16

const TYPES = [
	preload("res://Tiles/Types/Road.tscn"),
	preload("res://Tiles/Types/Mine.tscn"),
	#preload("res://Tiles/Types/Warehouse.tscn"),
	preload("res://Tiles/Types/Factory.tscn")
]

enum MOUSE_STATE { NONE, HOVER, HOLDING }
var mouse_state

var current_type = -1

# Called when the node enters the scene tree for the first time.
func _ready():
	set_colour(null)

func set_colour(colour):
	if colour:
		$Holder/Hex.set_colour(colour)
	else:
		$Holder/Hex.set_colour(Color.paleturquoise)

func _on_BaseTile_mouse_entered():
	if mouse_state == MOUSE_STATE.NONE:
		mouse_state = MOUSE_STATE.HOVER
	
	draw_mouse_state()

func _on_BaseTile_mouse_exited():
	mouse_state = MOUSE_STATE.NONE
	
	draw_mouse_state()

func _on_BaseTile_input_event(camera, event, click_position, click_normal, shape_idx):
	if event is InputEventMouseButton:
		if event.pressed:
			if mouse_state == MOUSE_STATE.HOVER:
				mouse_state = MOUSE_STATE.HOLDING
		else:
			if mouse_state == MOUSE_STATE.HOLDING:
				mouse_state = MOUSE_STATE.HOVER
				rotate_type()
		draw_mouse_state()

func draw_mouse_state():
	match mouse_state:
		MOUSE_STATE.NONE:
			$Holder.translation.y = 0
		MOUSE_STATE.HOVER:
			$Holder.translation.y = BOUNCE
		MOUSE_STATE.HOLDING:
			$Holder.translation.y = 2 * BOUNCE

func rotate_type():
	current_type += 1
	if current_type >= TYPES.size():
		current_type = -1
	
	set_type(current_type)

func set_type(val):
	for c in $Holder/Type.get_children():
		$Holder/Type.remove_child(c)
		set_colour(null)
	
	if val >= 0:
		var type = TYPES[val].instance()
		type.tile = self
		$Holder/Type.add_child(type)

extends Spatial

# I have to pull this in even though there's a class_name because that's
# the class and this is the scene
var base_tile = preload("res://Tiles/BaseTile.tscn")

const MAX_SIZE = 5
const MAX_BOTS = 250

var bot_pos
var texture

enum MOUSE_STATE { HOVERING, SELECTING }
var mouse_state = MOUSE_STATE.HOVERING

var selected = []
var menus = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	TaskManager.level = self
	bot_pos = Image.new()
	bot_pos.create(MAX_BOTS, 1, false, Image.FORMAT_RGBAF)
	texture = ImageTexture.new()
	texture.create_from_image(bot_pos, 0)
#	bot_pos.lock()
	$BotParticles.process_material.set_shader_param("bot_data", texture)
	$BotParticles.amount = MAX_BOTS
	
	var colours = [
		Color.blue,
		Color.paleturquoise,
		Color.pink
	]
	var bot = 0
	
	for i in range(-MAX_SIZE, MAX_SIZE + 1):
		for j in range(-MAX_SIZE, MAX_SIZE + 1):
			var blah = base_tile.instance()
			add_child(blah)
			colours.shuffle()
			# blah.set_colour(colours[0])
			blah.global_translate(Vector3.RIGHT * i + Vector3.RIGHT.rotated(Vector3.UP, PI/3) * j)
			blah.connect("mouse_entered", self, "_on_BaseTile_mouse_entered", [blah])
			blah.connect("mouse_exited", self, "_on_BaseTile_mouse_exited", [blah])
			blah.connect("input_event", self, "_on_BaseTile_input_event", [blah])
			
			if i == 0 and j == 0:
				blah.set_type(preload("res://Tiles/Types/Main.tscn"))
#			if (bot < MAX_BOTS):
#				bot_pos.set_pixel(bot, 0, Color(
#					blah.global_transform.origin.x,
#					blah.global_transform.origin.z,
#					1.0,
#					1.0
#				))
#				prints("Bots", bot, bot_pos.get_pixel(bot, 0))
#				bot += 1
			
#			bot = (bot + 1) % MAX_BOTS
#	bot_pos.unlock()
#	texture.set_data(bot_pos)

func set_bot_state(n, x, y, state):
	bot_pos.lock()
	bot_pos.set_pixel(n, 0, Color(
		x,
		y,
		state,
		1.0
	))
	bot_pos.unlock()
	texture.set_data(bot_pos)

func select_tile(tile):
	if not selected.has(tile):
		selected.append(tile)
	
	tile.select()
	
	add_tile_menu(tile)
	reconcile_menus()

func add_tile_menu(tile):
	var new_menus = tile.menus()
	if menus.empty():
		# Start out with all menus
		for menu in new_menus:
			menus[menu.get_path()] = menu
	else:
		# If there already are some, only keep the intersection
		for menu in menus:
			var p = false
			for nm in new_menus:
				if nm.get_path() == menu:
					p = true
					break
			
			if not p:
				menus.erase(menu)

func deselect_tile(tile):
	selected.erase(tile)
	tile.deselect()
	
	menus.clear()
	for tile in selected:
		add_tile_menu(tile)
	
	reconcile_menus()

func reconcile_menus():
	var copy = menus.duplicate()
	
	for child in $UI.get_children():
		if not copy.has(child.get_filename()):
			child.get_parent().remove_child(child)
			child.queue_free()
		else:
			copy.erase(child.get_filename())
	
	for key in copy:
		var inst = copy[key].instance()
		inst.level = self
		$UI.add_child(inst)

func clear_selection():
	for tile in selected:
		tile.deselect()
	menus.clear()
	selected.clear()
	reconcile_menus()

func _on_BaseTile_mouse_entered(tile):
	match mouse_state:
		MOUSE_STATE.HOVERING:
			tile.hover()
		MOUSE_STATE.SELECTING:
			if selected.has(tile) and Input.is_action_pressed("selection_add"):
				deselect_tile(tile)
			else:
				select_tile(tile)

func _on_BaseTile_mouse_exited(tile):
	match mouse_state:
		MOUSE_STATE.HOVERING:
			tile.unhover()

func _on_BaseTile_input_event(camera, event, click_position, click_normal, shape_idx, tile):
	if event is InputEventMouseButton:
		if event.pressed:
			if mouse_state == MOUSE_STATE.HOVERING:
				mouse_state = MOUSE_STATE.SELECTING
				
				if not Input.is_action_pressed("selection_add"):
					clear_selection()
				
				if selected.has(tile) and Input.is_action_pressed("selection_add"):
					deselect_tile(tile)
				else:
					select_tile(tile)
		else:
			if mouse_state == MOUSE_STATE.SELECTING:
				mouse_state = MOUSE_STATE.HOVERING

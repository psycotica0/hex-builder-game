extends Spatial

var base_tile = preload("res://Tiles/BaseTile.tscn")

const MAX_SIZE = 5
const MAX_BOTS = 250

var bot_pos
var texture

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

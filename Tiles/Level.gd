extends Spatial

var base_tile = preload("res://Tiles/BaseTile.tscn")

const MAX_SIZE = 10

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var colours = [
		Color.blue,
		Color.paleturquoise,
		Color.pink
	]
	
	for i in range(-MAX_SIZE, MAX_SIZE + 1):
		for j in range(-MAX_SIZE, MAX_SIZE + 1):
			var blah = base_tile.instance()
			add_child(blah)
			colours.shuffle()
			# blah.set_colour(colours[0])
			blah.global_translate(Vector3.RIGHT * i + Vector3.RIGHT.rotated(Vector3.UP, PI/3) * j)

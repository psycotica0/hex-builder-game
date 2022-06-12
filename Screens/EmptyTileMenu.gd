extends Control

var level

func _ready():
	pass

func build(type):
	for tile in level.selected:
		tile.build(type)
	level.clear_selection()

func _on_Road_pressed():
	build(preload("res://Tiles/Types/Road.tscn"))

func _on_Warehouse_pressed():
	build(preload("res://Tiles/Types/Warehouse.tscn"))

func _on_Mine_pressed():
	build(preload("res://Tiles/Types/Mine.tscn"))

func _on_Red_Factory_pressed():
	build(preload("res://Tiles/Types/Factory1.tscn"))


func _on_Bot_Factory_pressed():
	build(preload("res://Tiles/Types/Factory.tscn"))

extends Node

var network = AStar2D.new()

var buildings = {}
var roads = {}

func add_building(position):
	if buildings.has(position):
		return
	
	var id = network.get_available_point_id()
	network.add_point(id, position, 10)
	
	for road in adjacent_roads(position):
		network.connect_points(id, road)
	
	buildings[position] = id

func remove_building(position):
	if not buildings.has(position):
		return
	
	var id = buildings[position]
	buildings.erase(position)
	network.remove_point(id)

func add_road(position):
	if roads.has(position):
		return
	
	var id = network.get_available_point_id()
	network.add_point(id, position, 1)
	
	for road in adjacent_roads(position):
		network.connect_points(id, road)
	
	for building in adjacent_buildings(position):
		network.connect_points(id, building)
	
	roads[position] = id

func remove_road(position):
	if not roads.has(position):
		return
	
	var id = roads[position]
	roads.erase(position)
	network.remove_point(id)

func adjacent_roads(position):
	var ids = []
	for road in roads:
		var dist = position.distance_squared_to(road)
		if dist < 1.1 and dist > 0:
			ids.append(roads[road])
	
	return ids

func adjacent_buildings(position):
	var ids = []
	for building in buildings:
		var dist = position.distance_squared_to(building)
		if dist < 1.1 and dist > 0:
			ids.append(buildings[building])
	
	return ids

func get_id(position):
	if roads.has(position):
		return roads[position]
		
	if buildings.has(position):
		return buildings[position]
	
	return false

func find_path(position1, position2):
	return network.get_point_path(get_id(position1), get_id(position2))

func path_length(position1, position2):
	return find_path(position1, position2).size()

func are_connected(position1, position2):
	return not find_path(position1, position2).empty()

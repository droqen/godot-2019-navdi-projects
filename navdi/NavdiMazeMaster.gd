tool
extends TileMap
class_name NavdiMazeMaster

export var click_to_apply: bool
export var tileset_image: Texture

var bodies = {}

func _register(cell, body):
	if not bodies.has(cell):
		bodies[cell] = []
	if bodies[cell].find(body)<0:
		bodies[cell].append(body)
func _unregister(cell, body):
	if not bodies.has(cell):
		bodies[cell] = []
	bodies[cell].erase(body)
	
func get_bodies(cell):
	if bodies.has(cell):
		return bodies[cell]
	else:
		return []

func gett(cell):
	return get_cell(cell[0], cell[1])

func sett(cell, tile: int):
	return set_cell(cell[0], cell[1], tile)
	
func cell_to_world(cell):
	return map_to_world(Vector2(cell[0],cell[1]))
	
func cell_to_center(cell):
	return cell_to_world(cell) + cell_size / 2
	
func world_to_cell(world_position: Vector2):
	var map = world_to_map(world_position)
	return [int(map.x), int(map.y)]
	
func _process(_delta):
	if Engine.editor_hint and click_to_apply:
		click_to_apply = false
		tile_set = TileSet.new()
		var vframes: int = floor(tileset_image.get_height() / cell_size.y)
		var hframes: int = floor(tileset_image.get_width() / cell_size.x)
		print(vframes, " ", tileset_image.get_height(), " ", cell_size.y)
		var total_frame_count = vframes * hframes
		for i in range(total_frame_count):
			tile_set.create_tile(i)
			tile_set.tile_set_texture(i, tileset_image)
			tile_set.tile_set_region(i, Rect2(Vector2(i%hframes * cell_size.x, i/hframes * cell_size.y), cell_size))

func astarpath(a, b, funcref_cost, max_cost = 100, max_iters = 1000, verbose = false):
	if verbose:
		print("a* begin: Cell", a, " to Cell", b)
	var start_node = _make_astarnode(a)
	var open = {}
	var closed = {}
	open[start_node.cell] = start_node
	while not open.empty():
		max_iters -= 1
		if max_iters <= 0:
			print("a* max iters reached: Cell", a, " to Cell", b, " ... open cells remaining: ", len(open.keys()))
			break
		var here = _get_node_lowest_f(open)
		if verbose:
			print("a* #", max_iters, ": ", here)
		open.erase(here.cell)
		closed[here.cell] = here
		if here.cell == b:
			var path = []
			var cost = here.g
			while here.parent:
				path.append(here.cell)
				here = closed[here.parent]
			path.append(here.cell)
			path.invert()
			return {
				path = path,
				cost = cost
			} # end
		else:
			var connected_nodes = []
			var connection_costs = []
			var compass = [[1,0],[0,1],[-1,0],[0,-1]]
			compass.shuffle()
			for dir in compass:
				var there = _make_astarnode([here.cell[0] + dir[0], here.cell[1] + dir[1]], here.cell)
				var step_cost = funcref_cost.call_func(here.cell, there.cell)
				if here.g + step_cost <= max_cost:
					connected_nodes.append(there)
					connection_costs.append(step_cost)
			for i in range(len(connected_nodes)):
				var there = connected_nodes[i]
				var step_cost = connection_costs[i]
				if not closed.has(there.cell):
					var g = here.g + step_cost
					if open.has(there.cell):
						if g >= open[there.cell].g:
							continue
					var h = Vector2(b[0] - there.cell[0], b[1] - there.cell[1]).length()
					var f = g + h
					open[there.cell] = _make_astarnode(there.cell, there.parent, g, h, f)
					
	return {
		path = [a],
		cost = max_cost
	} # end. failed: no path found. do not move.

func _get_node_lowest_f(node_dict):
	var lowest_f_value = null
	var lowest_f_node = null
	for cell in node_dict.keys():
		var node = node_dict[cell]
		if lowest_f_value == null or node.f < lowest_f_value:
			lowest_f_value = node.f
			lowest_f_node = node
	return lowest_f_node

func _make_astarnode(cell,parent=null,g=0,h=0,f=0):
	return{cell = cell, parent = parent, g = g, h = h, f = f}

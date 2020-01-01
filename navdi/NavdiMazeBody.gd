extends RigidBody2D
class_name NavdiMazeBody

var maze: NavdiMazeMaster
var _cell
var lastMove
var centerOffset: Vector2 = Vector2()

func setup(maze, cell):
	self.maze = maze
	_cell = cell
	lastMove = [0, 0]
	self.position = maze.cell_to_center(cell)
	if is_inside_tree():
		maze._register(_cell, self)

func on_set_cell(cell):
	pass # do nothing
	
func is_move_legal(_from, _to) -> bool:
	return true
	
func try_set_cell(target) -> bool:
	if is_move_legal(_cell, target):
		lastMove = [ target[0]-_cell[0], target[1]-_cell[1] ]
		_set_cell(target)
		return true
	else:
		return false
		
func try_move(move) -> bool:
	return try_set_cell([_cell[0]+move[0], _cell[1]+move[1]])
		
func get_next_cell_in_path(path, from_cell = null):
	if from_cell == null:
		from_cell = _cell
	var next_cell_index = path.find_last(from_cell) + 1
	if next_cell_index <= 0 or next_cell_index >= len(path):
		return from_cell
	return path[next_cell_index]
func get_next_move_in_path(path, from_cell = null):
	if from_cell == null:
		from_cell = _cell
	var target = get_next_cell_in_path(path, from_cell)
	return [target[0] - from_cell[0], target[1] - from_cell[1]]
	
func get_center() -> Vector2:
	return maze.cell_to_center(_cell) + centerOffset
func vector_to_center() -> Vector2:
	return get_center() - position
	
func get_bodies_within_reach(reach):
	var reach_squared = reach * reach
	var bodies = []
	var radius = ceil(reach / maze.cell_size.x)
	for dx in range(-radius,radius+1):
		for dy in range(-radius,radius+1):
			for body in maze.get_bodies([_cell[0]+dx,_cell[1]+dy]):
				if body == self:
					continue
				if (body.position - self.position).length_squared() <= reach_squared:
					bodies.append(body)
	return bodies
	
func _exit_tree():
	if maze:
		maze._unregister(_cell, self)
func _set_cell(cell):
	maze._unregister(_cell, self)
	_cell = cell
	on_set_cell(_cell)
	maze._register(cell, self)
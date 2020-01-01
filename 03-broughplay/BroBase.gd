extends NavdiMazeNobody

func is_done_animating():
	return vector_to_center().length_squared() < 1

func bro_setup(maze, cell, frames):
	setup(maze, cell)
	get_node("NavdiBitsySprite").frames = frames

var myPathTarget

func get_move_cost(from, to) -> int:
	if to == myPathTarget:
		return 1
	elif maze.gett(to) == 1:
		return 2
	elif is_move_legal(from, to):
		return 1
	else:
		return 300

var stun_frames = 0
var is_stunned = false

func set_stun(stun_amount):
	stun_frames = stun_amount
	is_stunned = stun_amount % 2 == 1 or stun_amount > 10
	get_node("NavdiBitsySprite").set_flip_v(is_stunned)
	get_node("NavdiBitsySprite").rate = 2.0
	if is_stunned:
		get_node("NavdiBitsySprite").rate = 8.0

func is_move_legal(from, to) -> bool:
	for body in maze.get_bodies(to):
		return false
	return maze.gett(to) <= 0
	
func _physics_process(_delta):
	var approach = vector_to_center()
	var rate = .05 + approach.length() * .25
	if approach.length() > rate:
		approach = approach.normalized() * rate
	position += approach
	
var last_try_target
	
func try_move_path(target_cell):
	myPathTarget = target_cell
	var path = maze.astarpath(self._cell, target_cell, funcref(self, "get_move_cost"), 100, 1000)
	last_try_target = get_next_cell_in_path(path.path)
	return try_move([last_try_target[0] - _cell[0], last_try_target[1] - _cell[1]])
	
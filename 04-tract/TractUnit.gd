extends NavdiMazeNobody

func is_move_legal(_from, _to) -> bool:
	if _to[0] < 0: return false
	if _to[0] >= 10: return false
	if _to[1] < 0: return false
	if _to[1] >= 9: return false
	if len(maze.get_bodies(_to)) > 0:
		return false
	return maze.gett(_to) < 1

func _physics_process(_delta):
	var move = vector_to_center()
	if move.length() > 1:
		move = move.normalized() * 1
	else:
		var dirs = ChoiceStack.new([[1,0],[0,1],[-1,0],[0,-1]])
		dirs.remove_all([-lastMove[0], -lastMove[1]])
		lastMove = dirs.get_first_true(funcref(self,"try_move"), [0, 0])
	position += move
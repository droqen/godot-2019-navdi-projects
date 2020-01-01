extends NavdiXXI

onready var maze : NavdiMazeMaster = get_node('maze')

var cursor_value
var cursor_cell
var cursor

func _ready():
	init_bank()
	for x in range(10):
		for y in range(9):
			if randi()%3==0:
				spawn("unit", "units").setup(maze, [x, y])
	cursor = spawn("cursor")
	
func _physics_process(_delta):
	cursor_cell = maze.world_to_cell(get_viewport().get_mouse_position())
	cursor.position = maze.cell_to_center(cursor_cell)
	cursor.frames = [1]
	
	if Input.is_action_just_pressed("lmb"):
		match maze.gett(cursor_cell):
			0:
				cursor_value = 1
			1:
				cursor_value = 0
			_:
				cursor_value = -1
	if Input.is_action_pressed("lmb") and cursor_value >= 0:
		cursor.frames = [0]
		match maze.gett(cursor_cell):
			0, 1:
				maze.sett(cursor_cell, cursor_value)
extends NavdiXXI

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var maze: NavdiMazeMaster = get_node('maze')

var cursor_cell
var cursor

# Called when the node enters the scene tree for the first time.
func _ready():
	init_bank()
	randomize()
	var r = maze.get_used_rect()
	for x in range(int(r.position.x), int(r.end.x)+1):
		for y in range(int(r.position.y), int(r.end.y)+1):
			match maze.gett([x, y]):
				-1:
					maze.sett([x, y], 0)
				50:
					maze.sett([x, y], 0)
					spawn("friend").setup(maze, [x, y])
					
	cursor = spawn("cursor")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	cursor_cell = maze.world_to_cell(get_viewport().get_mouse_position())
	cursor.position = maze.cell_to_center(cursor_cell)
	if Input.is_action_just_pressed("lmb"):
		print('click detected @ ', cursor_cell)
		var friends = ChoiceStack.new().add_array(get_group("friends").get_children()).lock_tier()
		var nearest_friend = friends.get_highest(funcref(self, "_eval_path_to_cursor"))
		if nearest_friend:
			print('nearest friend found @ ', nearest_friend._cell)
			nearest_friend.set_target(cursor_cell)
			
func _eval_path_to_cursor(friend):
	var path = maze._make_astarpath(friend._cell, cursor_cell, funcref(friend, "get_travel_cost"))
	print('path from ', friend._cell, ' has cost of: ', path.cost)
	return -path.cost
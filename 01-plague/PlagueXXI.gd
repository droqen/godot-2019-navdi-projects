extends NavdiXXI

onready var maze = get_node("maze")

func _ready():
	init_bank()
#	OS.window_size *= 4
	randomize()
	for x in range(-6, 6+1):
		for y in range(-4, 4+1):
			if maze.gett([x,y]) != 1 and randi()%100<60:
				var human = spawn("human")
				human.setup(maze, [x,y])
				if randi()%100<30:
					human.become_sick()
				
	var humans = get_group("humans").get_children()	
	var player = humans[randi()%len(humans)]
	player.set_manual()
	player.become_immune()

var to_next_sick_test = 1

func _process(_delta):
	to_next_sick_test -= _delta
	if to_next_sick_test < 0:
		to_next_sick_test = 1
	else:
		return
	# count well humans
	var nobody_sick = true
	for human in get_group("humans").get_children():
		print("test human")
		if human.sick:
			nobody_sick = false
			break
	if nobody_sick:
		for human in get_group("humans").get_children():
			if human.manual_override:
				human.become_immune()
			elif randi()%100<50:
				human.become_sick()
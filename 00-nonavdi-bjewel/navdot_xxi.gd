extends Node2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var bank = get_node("navdot_bank")
	
func spawn(nodename, groupname=null, position=null):
	if bank.has_node(nodename):
		if groupname==null: groupname=nodename+"s"
		var group = getgroup(groupname)
		var n = bank.get_node(nodename).duplicate()
		group.add_child(n)
		if position!=null: n.position = position
		return n
	else:
		print("no node "+nodename+" exists")
	
func getgroup(groupname):
	if not has_node(groupname):
		var node = Node.new()
		node.set_name(groupname)
		add_child(node)
	return get_node(groupname)

func gridVec(cell):
	return Vector2(cell[0]*8,cell[1]*8)

# Called when the node enters the scene tree for the first time.
func _ready():
	remove_child(bank)
	spawn("player","players",gridVec([20/2, 1]))
	for x in range(0,20):
		for y in range(0,18):
			if x == 0 or y == 0 or x == 19 or y == 17:
				spawn("WALL").setup(self,[x,y])
			elif x == 1 or y == 1 or x == 18 or y == 16:
				pass
			else:
#				spawn("jewel").setup(self,[x,y])
				spawn(["jewel","jewelblue","jewelyellow"][randi()%3],"jewels").setup(self,[x,y])
			
	OS.window_size *= 4

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

extends NavdiXXI

var chara_rich

var rich_tileStrength: RichTextLabel

onready var maze = get_node("maze") as NavdiMazeMaster

var cursor_cell
var cursor

# Called when the node enters the scene tree for the first time.
func _ready():
	init_bank()
#	chara_rich = spawn("label", "labels", Vector2(4, 0)).get_node("text")
#	chara_rich.text = "Droqen\nhp: 50\n$0,050.19"

	rich_tileStrength = spawn("label", "labels", Vector2(4, 176)).get_node("text")
	
	cursor = spawn("cursor")
	
	randomize()
	var noise = OpenSimplexNoise.new()
	noise.seed = randi()
	noise.octaves = 4
	noise.period = 20.0
	noise.persistence = 0.8
	
	for x in range(1, 31):
		for y in range(1, 21):
			spawn_house([x, y], 0, 0)
#			var noiseval = noise.get_noise_2d(x, y)
#			if noiseval <= 0:
#				spawn_house([x, y], 0, noiseval)
#			else:
#				spawn_house([x, y], 1 + randi() % 3, noiseval)

	for x in range(1, 31):
		maze.sett([x, 0], 5)

func _physics_process(_delta):
	for i in range(10):
		update_house(get_random_house())
	cursor_cell = maze.world_to_cell(get_viewport().get_mouse_position())
	cursor.position = maze.cell_to_center(cursor_cell)
#	cursor.frames = [1]

	var houses = maze.get_bodies(cursor_cell)
	if len(houses) > 0:
		if Input.get_action_strength("lmb") > 0:
			var contig_houses = get_contiguous_houses(houses[0])
			var has_strength = false
			for house in contig_houses:
				if house.strength >= 0.2:
					house.strength -= 0.2
					has_strength = true
					break
				else:
					house.strength = 0.0
			if not has_strength:
				for house in contig_houses:
					set_house_id(house, 4)
		rich_tileStrength.text = str(houses[0].strength)
	else:
		rich_tileStrength.text = "-.-"

func get_random_house() -> House_Nobody:
	return get_node("houses").get_child(randi() % get_node("houses").get_child_count()) as House_Nobody

func spawn_house(cell, id, noiseval):
	var house = spawn("house", "houses")
	house.setup(maze, cell)
#	house.strength = int(clamp(3 + 10 * noiseval, 1, 6))
	set_house_id(house, id)
		
func set_house_id(house, id):
	if house.id != id:
		house.id = id
		house.strength = 0.0
#	match id:
#		0:
#			house.get_node("spr").frames = [02, 03]
#		1:
#			house.get_node("spr").frames = [12, 13]
#		2:
#			house.get_node("spr").frames = [22, 23]
#		3:
#			house.get_node("spr").frames = [32, 33]
			
func get_contiguous_houses(house):
	var skip_cells = {}
	var touching_cells = [house._cell]
	var touching_houses = {}
	var touching_count = 1
	var index = 0
	while index < touching_count:
		if not skip_cells.has(touching_cells[index]):
			skip_cells[touching_cells[index]] = true
			var houses_here = maze.get_bodies(touching_cells[index])
			if len(houses_here) > 0 and houses_here[0].id == house.id:
				touching_houses[touching_cells[index]] = houses_here[0]
				for cell in get_neighbourly_cells(touching_cells[index]):
					if not touching_houses.has(cell):
						touching_cells.append(cell)
						touching_count += 1
		index += 1
	return touching_houses.values()
			
func get_neighbourly_cells(cell):
	var cells = []
	cells.append([cell[0] + 1, cell[1] + 0])
	cells.append([cell[0] + 0, cell[1] + 1])
	cells.append([cell[0] - 1, cell[1] + 0])
	cells.append([cell[0] + 0, cell[1] - 1])
	return cells
			
func get_adjacent_houses(house):
	var nearby_houses = []
	nearby_houses += maze.get_bodies([house._cell[0] + 0, house._cell[1] + 0])
	nearby_houses += maze.get_bodies([house._cell[0] + 1, house._cell[1] + 0])
	nearby_houses += maze.get_bodies([house._cell[0] + 0, house._cell[1] + 1])
	nearby_houses += maze.get_bodies([house._cell[0] - 1, house._cell[1] + 0])
	nearby_houses += maze.get_bodies([house._cell[0] + 0, house._cell[1] - 1])
	return nearby_houses
			
func update_house(house):
	var nearby_houses = get_adjacent_houses(house)
	var counts = [0, 0, 0, 0, 0]
	
	for n in nearby_houses:
		if n.id == 0:
			counts[n.id] += 1
		else:
			counts[n.id] += n.strength
			
	counts[4] *= 1.1
			
#	counts[randi() % 3 + 1] *= 1.02
	
	for i in range(4):
		if counts[i + 1] > counts[(i + 1) % 4 + 1] + counts[(i + 2) % 4 + 1] + counts[(i + 3) % 4 + 1]:
			set_house_id(house, i + 1)
			
	if house.id == 0 and randi() % 100 == 0:
		set_house_id(house, randi() % 3 + 1)
	
	house.strength = clamp(house.strength + .1, 0, 1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

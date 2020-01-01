extends NavdiXXI

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var maze : NavdiMazeMaster = get_node('maze')

var player
var player_hp = 4
var player_anim = 0
var enemy_anim = 0

var shrines_touched = {}
var shrine_ids = [13,14,15, 23,24,25, 33,34,35]
var shrine_positions = [[4, 4], [4, 13], [4, 22], 
[13, 4], [13, 13], [13, 22], 
[22, 4], [22, 13], [22, 22]]
var dotties = []

func reset():
	randomize()
	shrine_positions.shuffle()
	for i in range(9):
		shrines_touched[i] = false
		maze.sett(shrine_positions[i], shrine_ids[i])
	for x in range(0,9*3):
		for y in range(0,9*3):
			var val = maze.gett([x,y])
			if val == 0 or val == 1:
				maze.sett([x,y], randi()%2)
	
	if player != null:
		_set_hp(4)
		player._set_cell(shrine_positions[0])
		
	for foe in _get_foes():
		foe.queue_free()
		
	spawn("friend", "foes").bro_setup(maze, shrine_positions[8], [60, 61])
	
	player_anim = 0
	enemy_anim = 30
	_update_dotties()

# Called when the node enters the scene tree for the first time.
func _ready():
	init_bank()
	for i in range(9):
		var dotty = spawn("dotty", "Camera2D")
		dotties.append(dotty)
	reset()
	player = spawn("friend")
	player.bro_setup(maze, shrine_positions[0], [50, 51, 50, 52])
#	player.bro_setup(maze, shrine_positions[0], [50, 51, 50, 52])

	

#	spawn("friend", "foes").bro_setup(maze, shrine_positions[8], [60, 61])

func _update_dotties():
	for i in range(9):
		dotties[i].position = Vector2(-36 + 1 + shrine_positions[i][0] / 4.5, -36 + 1 + shrine_positions[i][1] / 4.5)
		dotties[i].frames = [80, 90]
		if shrines_touched[i]:
			dotties[i].frames = [81, 91]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if player_hp <= 0:
		if Input.is_action_just_pressed('right') or Input.is_action_just_pressed('left') or Input.is_action_just_pressed('down') or Input.is_action_just_pressed('up'):
			reset()
			return
			
	var pin_just = Vector2()
	if Input.is_action_just_pressed('right'): pin_just.x += 1
	if Input.is_action_just_pressed('left'): pin_just.x -= 1
	if Input.is_action_just_pressed('down'): pin_just.y += 1
	if Input.is_action_just_pressed('up'): pin_just.y -= 1
	
	if player_anim <= 0 and (enemy_anim <= 0 or pin_just.length_squared() == 1):
		if player_hp <= 0:
			player_anim = randi()%30 + 30
		elif enemy_anim <= 8:
			var pin = Vector2()
			if enemy_anim <= 0:
				if Input.is_action_pressed('right'): pin.x += 1
				if Input.is_action_pressed('left'): pin.x -= 1
				if Input.is_action_pressed('down'): pin.y += 1
				if Input.is_action_pressed('up'): pin.y -= 1
			else:
				pin = pin_just
			if pin.length_squared() == 1:
				var target_cell = [player._cell[0] + int(pin.x), player._cell[1] + int(pin.y)]
				var player_did_action = false
				if player.try_set_cell(target_cell):
					player_did_action = true
				else:
					var touched = maze.gett(target_cell)
					if touched == 1:
						player_did_action = true
						maze.sett(target_cell, 0)
					
					var shrine_touched = shrine_ids.find(touched)
					if shrine_touched >= 0:
						player_did_action = true
						activate_shrine(shrine_touched)
						maze.sett(shrine_positions[shrine_touched], shrine_ids[shrine_touched] + 3)
						_update_dotties()
					
					for foe in _get_foes():
						if foe._cell == target_cell:
							player_did_action = true
							foe._set_cell(shrine_positions[8])
#							if not foe.is_stunned:
#								_set_hp(player_hp - 1)
#					player.position += pin * 4
					
				if player_did_action:
					player.position += pin * 3.9
					player_anim = 8
			
	var player_cell = maze.world_to_cell(player.position)
	var player_room_cell = [int(floor(player_cell[0] / 9.0)) * 9 + 4, int(floor(player_cell[1] / 9.0)) * 9 + 4]
	get_node("Camera2D").position = maze.cell_to_center(player_room_cell)

func activate_shrine(shrine_id):
	if not shrines_touched[shrine_id]:
		shrines_touched[shrine_id] = true
		match shrine_id:
			0:
				_set_hp(4)
			1:
				for x in range(9*3):
					for y in range(9*3):
						if maze.gett([x,y]) == 0:
							maze.sett([x,y], 1)
						elif maze.gett([x,y]) == 1:
							maze.sett([x,y], 0)
			2:
				for foe in _get_foes():
					var foe2 = spawn("friend", "foes")
					foe2.bro_setup(maze, foe._cell, [60, 61])
					foe2.set_stun(2)
			3:
				for foe in _get_foes():
					foe.set_stun(15)
			4:
				shrine_positions.shuffle()
				for i in range(9):
					var sid = shrine_ids[i]
					if shrines_touched[i]:
						sid += 3
					maze.sett(shrine_positions[i], sid)
			5:
				for i in range(9):
					if i != 5:
						shrines_touched[i] = false
						maze.sett(shrine_positions[i], shrine_ids[i])
			6:
				for x in range(9*3):
					for y in range(9*3):
						if maze.gett([x,y])==1:
							maze.sett([x,y],0)
			7:
				for roomx in range(3):
					for roomy in range(3):
						for subpos in [
						[4,0], [0,4], [4,8], [8,4],
						[4,5], [5,4], [4,3], [3,4],
						[5,5], [3,5], [5,3], [3,3]]:
							maze.sett([subpos[0] + roomx * 9, subpos[1] + roomy * 9], 1)
			8:
				var foe = spawn("friend", "foes")
				foe.bro_setup(maze, shrine_positions[8], [60, 61])
				foe.set_stun(1)

func _get_foes():
	if get_node("foes"):
		return get_node("foes").get_children()
	else:
		return []

func _physics_process(_delta):
	if player_anim > 0:
		player_anim -= 1
		if player_anim <= 0:
			enemy_anim = 12
			for foe in _get_foes():
				if foe.is_stunned:
					pass
				elif foe.try_move_path(player._cell):
					pass
				else:
					var target = foe.last_try_target
					var dir = [target[0] - foe._cell[0], target[1] - foe._cell[1]]
					if target == player._cell:
						foe.position += Vector2(dir[0], dir[1]) * 5
						_set_hp(player_hp - 1)
					if maze.gett(target) == 1:
						foe.position += Vector2(dir[0], dir[1]) * 5
						maze.sett(target, 0)
						
				if foe.stun_frames > 0:
					foe.set_stun(foe.stun_frames - 1)
	if enemy_anim > 0:
		enemy_anim -= 1
		
func _set_hp(hp):
	if hp < 0:
		hp = 0
	player_hp = hp
	var rate: float = 3
	var frames = [50, 51, 50, 52]
	var frames_offset = 0
	match hp:
		4:
			pass
		3:
			rate += 2
			frames_offset = 5
		2:
			rate += 4
			frames_offset = 15
		1:
			rate += 6
			frames_offset = 25
		0:
			frames = [85]
	
	for i in range(len(frames)):
		frames[i] += frames_offset
	var bitsySprite = player.get_node("NavdiBitsySprite") as NavdiBitsySprite
	bitsySprite.frames = frames
	bitsySprite.rate = rate
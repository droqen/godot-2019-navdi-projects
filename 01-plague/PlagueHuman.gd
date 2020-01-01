extends NavdiMazeBody
func is_move_legal(_from, _target) -> bool:
	return maze.gett(_target) != 1
func on_set_cell(cell):
	centerOffset = Vector2(rand_range(-6,6+1),rand_range(-8,4+1))

# class_name PlagueHuman
var manual_override = false
var stuck_frames = 0
var last_velocity = Vector2()
var debug_name
var duration = 0
var sick = false
var immune = false

signal became_well

# Called when the node enters the scene tree for the first time.
func _ready():
	debug_name = "human#"+str(randi()%100)
	get_node("Cursor").hide()
	
func set_manual():
	get_node("Cursor").show()
	manual_override = true
	
func become_sick():
	if not immune:
		sick = true
		immune = false
		duration = rand_range(1,10)
		if manual_override:
			duration = rand_range(3,8)
		var sprite = (get_node("Sprite") as NavdiBitsySprite)
		sprite.frames = [60,61,60,62]
func become_immune():
	sick = false
	immune = true
	duration = rand_range(3,10)
	if manual_override:
		duration = rand_range(4,7)
	var sprite = (get_node("Sprite") as NavdiBitsySprite)
	sprite.frames = [70,71,70,72]
	emit_signal("became_well")
func become_well():
	sick = false
	immune = false
	var sprite = (get_node("Sprite") as NavdiBitsySprite)
	sprite.frames = [50,51,50,52]
	emit_signal("became_well")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
		
	if duration > 0:
		duration -= delta
		if duration <= 0:
			if sick: become_immune()
			elif immune: become_well()
			else: pass
	
	var _speed = 20
	if sick:
		_speed = 10
	
	if manual_override:
		_speed *= 1.5
		var pin = Vector2()
		if Input.is_action_pressed('right'): pin.x += 1
		if Input.is_action_pressed('left'): pin.x -= 1
		if Input.is_action_pressed('down'): pin.y += 1
		if Input.is_action_pressed('up'): pin.y -= 1
		
		self.linear_velocity = self.linear_velocity * .5 + .5 * pin.normalized() * _speed
#		linear_velocity = linear_velocity * .5 + .5 * vector_to_center().normalized() * _speed
	else:
		if (linear_velocity - last_velocity).length_squared() > .1:
			stuck_frames += 1
			if stuck_frames > 30:
				stuck_frames = 0
				_set_cell(maze.world_to_cell(position))
				var dirs = ChoiceStack.new().add_array(NavdiAutoUtils.compass).lock_tier().remove_all(lastMove)
				lastMove = dirs.get_first_true(funcref(self, "try_move"), [0,0])
		else:
			stuck_frames = 0
		
		linear_velocity = linear_velocity * .5 + .5 * vector_to_center().normalized() * _speed
		last_velocity = linear_velocity
		
		if vector_to_center().length_squared() < 2 * 2:
			var dirs = ChoiceStack.new().add_array(NavdiAutoUtils.compass).lock_tier().remove_all([-lastMove[0], -lastMove[1]])
			lastMove = dirs.get_first_true(funcref(self, "try_move"), [0,0])

func _on_human_body_entered(body):
	if body.get("sick"):
		become_sick()

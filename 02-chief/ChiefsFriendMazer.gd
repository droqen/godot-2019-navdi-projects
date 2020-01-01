extends NavdiMazeBody

const ACCEL_RATE = .5
const ANIM_MIN_RATE = 0
const ANIM_MAX_RATE = 4
const SPEED = 40

var blocked_frames = 0
var unblocked_velocity: Vector2 = Vector2()
var thinking: int = int(rand_range(0, 5))
var target = null

func set_target(target):
	self.target = target

func _physics_process(_delta):
	
	if vector_to_center().length_squared() < 2 * 2 and target != null:
		var path = maze.astarpath(_cell, target, funcref(self, "get_travel_cost"), 100).path
		var move = get_next_move_in_path(path)
		try_move(move)
		adjust_velocity(vector_to_center() / 2 * SPEED)
	else:
		adjust_velocity(vector_to_center().normalized() * SPEED)
		
	var anim_rate = lerp(ANIM_MIN_RATE, ANIM_MAX_RATE, inverse_lerp(0, SPEED, linear_velocity.length()))
	get_node("NavdiBitsySprite").rate = anim_rate
	if anim_rate <= .5:
		get_node("NavdiBitsySprite").ani = 0
	
func adjust_velocity(target_velocity):
	linear_velocity = linear_velocity * (1 - ACCEL_RATE) + ACCEL_RATE * target_velocity
	unblocked_velocity = linear_velocity
	
func check_blocked(sensitivity = .1):
	if (unblocked_velocity - linear_velocity).length_squared() < sensitivity * sensitivity:
		blocked_frames += 1
	return blocked_frames
	
func get_travel_cost(a, b):
	if maze.gett(b) > 0:
		return 100
	else:
		return 1
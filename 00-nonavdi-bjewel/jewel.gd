extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var jewel_id = 0

var spring_vectorweak = Vector2(0,0)
var spring_diagweak = false

var spring_damp = .5
var spring_strength = 1
var spring_brittle = .5
var base_anim_rate = 1

var XXI
var cell

func setup(XXI,cell):
	self.XXI = XXI
	self.cell = cell
	self.position = XXI.gridVec(cell)
	var rot = 90*(randi()%4)
	for n in get_children():
		n.position = n.position.rotated(deg2rad(rot))
		n.rotation_degrees = rot
		
	spring_damp = .7
	spring_strength = 20
	spring_brittle = 4
	base_anim_rate = .5 + fmod(randf(),.5)
		
	if jewel_id==0: # red
		spring_strength *= 3
		spring_vectorweak = Vector2(0, 1).rotated(deg2rad(rot))
		print(spring_vectorweak)
	elif jewel_id==1: # blue
		spring_strength *= 3
		spring_diagweak = true
	elif jewel_id==2: # yellow
		spring_strength *= 1.8
	elif jewel_id==3: # wall
		spring_strength *= 4 # simply too strong

	spring_strength *= .80 + fmod(randf(),1.10-.80)
	spring_damp *= .80 + fmod(randf(),1.10-.80)

# Called when the node enters the scene tree for the first time.
func _ready():
	get_node("Sprite").ani = fmod(randf(),2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
	var to_centered = (XXI.gridVec(cell)-self.position)
	var center_dist = to_centered.length()
	
	var _damp = spring_damp
	var _brit = spring_brittle
	var _str = spring_strength
	if center_dist < 2: _str *= center_dist / 2
	
	if spring_vectorweak != Vector2():
		var _angle = abs(rad2deg(spring_vectorweak.angle_to(-to_centered)))
		if _angle<90:
			_str *= .3
		if _angle<45:
			_brit *= .3
	
	if spring_diagweak and center_dist >= .316:
		var dx = abs(to_centered.normalized().x)
		var dy = abs(to_centered.normalized().y)
		if dx < .9 and dy < .9:
			_str *= .5
			_brit *= .5
	
	self.linear_velocity *= (1-_damp)
	self.linear_velocity += (_damp) * to_centered.normalized() * _str
	if center_dist > _brit:
		queue_free()
#	self.linear_velocity = self.linear_velocity.slerp((XXI.gridVec(cell) - self.position) * spring_strength, spring_damp)
	get_node("Sprite").rate = base_anim_rate * pow( lerp(1,4,inverse_lerp(0, _brit, center_dist)), 2 )
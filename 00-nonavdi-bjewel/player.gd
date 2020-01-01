extends RigidBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var speed = 80
var pin = Vector2()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(_delta):
#	pin.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	pin.x = 0
	pin.y = 0
	if Input.is_action_pressed('ui_right'): pin.x += 1
	if Input.is_action_pressed('ui_left'): pin.x -= 1
	if Input.is_action_pressed('ui_down'): pin.y += 1
	if Input.is_action_pressed('ui_up'): pin.y -= 1
	
	self.linear_velocity = self.linear_velocity * .5 + .5 * (pin.normalized() * speed + 10 * _to_round_pos())
	
func _to_round_pos():
	var rpos = Vector2(round(self.position.x*.125)*8,round(self.position.y*.125)*8)
	return rpos - self.position
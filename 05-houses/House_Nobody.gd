extends NavdiMazeNobody

class_name House_Nobody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var id
var strength: float = .1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = maze.cell_to_center(_cell)
	var base_frame = 2
	var frame_plus = 1
	match id:
		0:
			base_frame = 0
			frame_plus = 0
		1:
			base_frame = 12
		2:
			base_frame = 22
		3:
			base_frame = 32
		4:
			base_frame = 42
			
	if id > 0:
		match int(floor(strength * 3)):
			0:
				base_frame -= 1
				frame_plus = 0
			1:
				base_frame -= 1
			2:
				pass
			3:
				base_frame += 1
				frame_plus = 0
			
	get_node("spr").rate = 1.0 + 3 * strength
	get_node("spr").frames = [base_frame, base_frame + frame_plus]
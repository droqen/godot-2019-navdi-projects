tool
extends Sprite
export var frames = [0,1]
export var rate = 5
var ani = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	ani = fmod(ani + delta * rate, len(frames))
	frame = frames[int(ani)]

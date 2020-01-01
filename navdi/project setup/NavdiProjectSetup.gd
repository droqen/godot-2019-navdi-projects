tool
extends Node

export var apply_on_click = false
export var width: int = 160
export var height: int = 144
export var zoom: int = 3
export var project_name: String = "Unnamed Navdi Project"

func _ready():
	if not Engine.editor_hint:
		queue_free()
	
func _process(_delta):
	if Engine.editor_hint and apply_on_click:
		apply_on_click = false
		ProjectSettings.set("network/limits/debugger_stdout/max_errors_per_frame",100)
#		print("Set max errors per frame to 100")
		ProjectSettings.set("display/window/stretch/mode","viewport")
#		print("Set stretch mode to 'viewport'")
		ProjectSettings.set("rendering/quality/2d/use_pixel_snap",true)
#		print("Set 2d/pixel snap to true")
		ProjectSettings.set("display/window/size/width", width)
		ProjectSettings.set("display/window/size/height", height)
		ProjectSettings.set("display/window/size/test_width", width * zoom)
		ProjectSettings.set("display/window/size/test_height", height * zoom)
#		print("Set width x height to ", width, " x ", height)
		ProjectSettings.set("application/config/name", project_name)
		
		ProjectSettings.set("application/run/main_scene", get_tree().edited_scene_root.filename)
		
		print("Applied Navdi 2d project settings for '", project_name, "' viewed @ ", width, "x", height)
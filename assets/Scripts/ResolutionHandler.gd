extends Node
class_name ResolutionHandler

static var scale_factor : int = 6
static var window : Window

func _ready():
	window = get_window()
	window.size_changed.connect(change_resolution)

func change_resolution():
	#window.size = Vector2i(320, 180) * scale_factor
	DisplayServer.window_set_size(window.size,0)
	return

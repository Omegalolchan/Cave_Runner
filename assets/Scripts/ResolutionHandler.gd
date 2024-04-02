extends Node

var scale_factor : int = 6

func _ready():
	get_viewport().size = Vector2i(320, 180) * scale_factor
	pass

func _process(_delta):
	pass

func change_resolution():
	get_viewport().size = Vector2i(320, 180) * scale_factor
	return
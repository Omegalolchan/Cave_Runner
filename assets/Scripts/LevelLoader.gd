extends Node
class_name LevelLoader

@onready var viewport = get_node('SubViewportContainer/SubViewport')
var _current_level : PackedScene
var _current_level_part : String

func load_level(path : String):
	_current_level = load(path)
	print()
	var loaded_level = viewport.get_children()
	if loaded_level.size() > 0:
		for i in loaded_level:
			i.free()
	
	viewport.add_child(_current_level.instantiate())

func _ready():
	#if _current_level == null:
	#	load_level("res://assets/Scenes/Debug Scene.tscn")
	pass

func get_current_level() -> String:
	var string = _current_level.resource_path
	string = string.split("/")[-1] # this removes the full path and only shows the file name + extension
	string = string.split(".")[0]  # this removes the extension (.tscn)
	return string

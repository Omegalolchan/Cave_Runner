extends Node

var player : Player
var _current_scene_type : current_scene_type = current_scene_type.MENU
var _current_scene_file_name : String
var _main_node : Node
var managers = {
	checkpoint_manager = null,
}
enum current_scene_type{
	MENU,
	LEVEL,
}

func _default():
	for i in get_children():
		i.free()
	managers = {
		checkpoint_manager = null,
	}
	return

func initialize_and_update_references(update_main_node : bool):
	if update_main_node : 
		_main_node = get_node('/root/Node')
	if _main_node is LevelLoader and player != null:
		_current_scene_type = current_scene_type.LEVEL
		managers['checkpoint_manager'] = CheckpointManager.new()
		add_child(managers['checkpoint_manager'])

func _ready() -> void:
	initialize_and_update_references(true)
	# {{{ every scene is in assets/scenes/ so i delete the file path string to res://assets/Scenes/FILENAME.tscn to FILENAME
	_current_scene_file_name = _main_node.scene_file_path
	_current_scene_file_name = _current_scene_file_name.erase(_current_scene_file_name.length() - 5, 5)
	_current_scene_file_name = _current_scene_file_name.erase(0, 20)
	# }}}
	return

func change_scene(scene : String) -> void:
	_default()
	_main_node.free()
	var scene_to_load : PackedScene 
	if scene != "LevelLoader":
		scene_to_load = load('res://assets/Scenes/' + scene + '.tscn')
	else:
		scene_to_load = load('res://assets/Objects/LevelLoader.tscn')
	_main_node = scene_to_load.instantiate()
	_current_scene_file_name = scene
	get_tree().root.add_child(_main_node)
	initialize_and_update_references(false)
	pass

func get_current_scene_type():
	return _current_scene_type

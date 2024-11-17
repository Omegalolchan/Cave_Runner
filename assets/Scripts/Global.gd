extends Node

var player : Player
var _current_scene : current_scene_type = current_scene_type.MENU
var managers = {
	checkpoint_manager = null
}
enum current_scene_type{
	MENU,
	LEVEL,
}

func _ready() -> void:
	var main_node = get_node('/root/Node')
	if main_node is LevelLoader:
		_current_scene = current_scene_type.LEVEL
		managers['checkpoint_manager'] = CheckpointManager.new()
		add_child(managers['checkpoint_manager'])
	return

func change_scene(scene : String) -> void:
	print(scene)
	pass

func get_current_scene_type():
	return _current_scene

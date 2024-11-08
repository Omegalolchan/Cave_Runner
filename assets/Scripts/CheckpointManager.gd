extends Node
class_name CheckpointManager

var current_checkpoint_position : Vector2 = Vector2(0,0)
var current_checkpoint_scene : StringName 
var backup_checkpoint_position : Vector2 = Vector2(0,0)
func update_checkpoint(position : Vector2, scene : StringName):
	backup_checkpoint_position = current_checkpoint_position
	current_checkpoint_scene = scene
	current_checkpoint_position = position
	return

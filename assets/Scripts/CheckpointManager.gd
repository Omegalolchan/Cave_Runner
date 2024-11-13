extends Node
class_name CheckpointManager

var current_checkpoint_position : Vector2 = Vector2(0,0)
var current_checkpoint_scene : StringName 
var backup_checkpoint_position : Vector2 = Vector2(0,0)

func _ready() -> void:
	var player_path : String = Global.player.get_path() 
	get_node(player_path + '/Sprite' ).death_animation_finished.connect(_on_death_animation_finished)
	#print(Global.player)

func update_checkpoint(position : Vector2, scene : StringName):
	backup_checkpoint_position = current_checkpoint_position
	current_checkpoint_scene = scene
	current_checkpoint_position = position
	return

func _on_death_animation_finished():
	Global.player.dead = false
	Global.player.position = current_checkpoint_position
	pass

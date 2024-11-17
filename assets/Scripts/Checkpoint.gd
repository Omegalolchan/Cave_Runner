extends Node2D

@onready var checkpoint_manager : CheckpointManager = Global.managers['checkpoint_manager']

func _on_body_enter(_body : Node2D):
	if _body is Player and checkpoint_manager != null:
		checkpoint_manager.update_checkpoint(position, 'debug')
		print("checkpoint")
	pass

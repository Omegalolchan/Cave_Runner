extends Node2D

@onready var checkpoint_manager : CheckpointManager = get_node('/root/checkpoint_manager')

func _on_body_enter(_body : Node2D):
	if _body is Player:
		checkpoint_manager.update_checkpoint(position, 'debug')
		print("checkpoint")
	pass

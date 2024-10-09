extends Node

var position
@onready var player : Player = get_node('../Player')
func _on_check_point_0_body_entered(_node : Node2D):
	position = _node.position

func _on_player_death():
	player.position = position
	player.added_velocity = Vector2(0,0)
	player.velocity = Vector2(0,0)
	return
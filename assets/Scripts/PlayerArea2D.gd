extends Area2D

@onready var player : Player = get_node('../../Player')

func _physics_process(_delta):
	if get_overlapping_bodies():
		player.die()
	return

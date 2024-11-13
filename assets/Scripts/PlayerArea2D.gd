extends Area2D

@onready var player : Player = get_node('../../Player')

func _physics_process(_delta):
	var bodies : Array[Node2D] = get_overlapping_bodies()
	if bodies.size() > 0:
		get_node('../Sprite').update_death_push(Vector2.ZERO, .5)
		player.die()
	return

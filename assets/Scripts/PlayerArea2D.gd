extends Area2D

@onready var player : Player = Global.player

func _ready() -> void:
	self.body_entered.connect(on_area_enter)	

func on_area_enter(_body : Node2D):
	get_node('../Sprite').update_death_push(Vector2.ZERO, 20)
	player.die()
	return

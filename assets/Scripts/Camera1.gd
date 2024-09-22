extends Camera2D

var player

# Called when the node enters the scene tree for the first time.
func _ready():
	player = get_node('../Player')
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = player.position
	pass
